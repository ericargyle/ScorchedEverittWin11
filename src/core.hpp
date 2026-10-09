#pragma once
// Portable translation of SCORCH.ASM (ECE291, 2001). All positions are in the
// original 640x480 screen, NOT relative to the landscape at (0,14).
// Build without fast-math / with FP contraction disabled. Portable libm and
// long double approximate x87 FSINCOS/extended intermediates (MSVC long double
// is binary64); pathological near-halfway results are not bit-exact guaranteed.
// Binary32 stored constants/velocities/time and FISTP tie behavior are preserved.
// Valid gameplay launch inputs: power 0..100, angle 0..180, screen origin.
// Rendering, audio, crater rasterization and the broken _GetWind fall-through
// into _FiringSound are intentionally caller responsibilities.
#include <algorithm>
#include <cmath>
#include <cstdint>
#include <limits>
#include <stdexcept>

namespace scorch {
struct Point { int x, y; };
inline constexpr bool operator==(Point a, Point b) { return a.x==b.x && a.y==b.y; }
inline constexpr Point tankCoords[10][2] = {
 {{105,224},{541,273}},{{82,173},{509,200}},{{3,162},{504,172}},
 {{73,359},{495,306}},{{72,179},{469,349}},{{119,217},{479,167}},
 {{96,236},{458,208}},{{86,225},{445,200}},{{100,217},{520,292}},
 {{109,221},{447,224}}
};
inline constexpr Point muzzle[6][10] = {
 {{60,25},{58,13},{54,5},{45,0},{33,0},{26,0},{14,0},{5,5},{1,13},{0,25}},
 {{59,29},{56,18},{49,10},{40,5},{30,4},{29,4},{19,5},{10,10},{3,18},{0,29}},
 {{59,26},{56,17},{50,8},{42,2},{30,0},{29,0},{17,2},{9,8},{3,17},{0,26}},
 {{54,24},{53,18},{49,12},{44,9},{38,8},{21,8},{15,9},{10,12},{6,18},{5,24}},
 {{59,26},{58,19},{54,12},{48,8},{40,7},{19,7},{11,8},{5,12},{1,19},{0,26}},
 {{54,27},{53,22},{48,14},{44,10},{35,8},{24,8},{15,10},{11,14},{6,22},{5,27}}
};
inline constexpr int frameAngles[10]={0,22,44,66,89,91,114,136,158,180};
// Original sprite changes ONLY on these exact angles, in either direction.
// This is intentionally stateful: angle 21 can have frame 0 OR frame 1.
inline int updateTankFrame(int previousFrame, int angle) {
 for(int i=0;i<10;++i) if(angle==frameAngles[i]) return i;
 return previousFrame;
}
inline Point shotOrigin(int land, int player, int model, int frame) {
 if(land<0||land>=10||player<1||player>2||model<1||model>6||frame<0||frame>=10)
  throw std::out_of_range("tank selection");
 auto a=tankCoords[land][player-1], b=muzzle[model-1][frame];
 return {a.x+b.x,a.y+b.y};
}
// x/y remain the fixed launch origin. sample returns the next absolute point,
// then DOUBLES t (not t += dt). Join successive points with traceBullet.
struct Shot { float x,y,vx,vy,t; };
inline Shot launch(Point origin, int power, int angle) {
 // dd 0.017453 is deliberately not pi/180. FSTP rounds velocities to binary32.
 const long double theta=static_cast<long double>(angle)*0.017453f;
 return {static_cast<float>(origin.x),static_cast<float>(origin.y),
  static_cast<float>(std::cos(theta)*power),static_cast<float>(std::sin(theta)*power),0.001f};
}
// FINIT/FISTP: nearest integer, ties to even, independent of caller rounding mode.
inline std::int32_t nearestEven(long double v) {
 if(!std::isfinite(v)) return std::numeric_limits<std::int32_t>::min();
 long double lo=std::floor(v), fraction=v-lo;
 if(fraction>0.5L || (fraction==0.5L && std::fmod(lo,2.0L)!=0)) ++lo;
 if(lo < -2147483648.0L || lo > 2147483647.0L) return std::numeric_limits<std::int32_t>::min();
 return static_cast<std::int32_t>(lo);
}
inline int signedWord(unsigned v) { v&=65535u; return v<32768u?int(v):int(v)-65536; }
// wind is the RAW _Wind word, not an intuitive signed breeze. Low byte's sign
// chooses subtraction, while FIADD/FISUB uses the signed full word (ASM 2055).
// Pass zero for the original executable: _GetWind is commented out entirely.
inline Point sample(Shot& s, int wind=0) {
 const int w=signedWord(static_cast<unsigned>(wind));
 const long double vx=static_cast<long double>(s.vx)+((wind&128)?-w:w);
 const auto dx=nearestEven(vx*s.t);
 const auto dy=nearestEven((-5.0L*s.t+static_cast<long double>(s.vy))*s.t);
 const auto wrap=[](std::int64_t n) {auto u=static_cast<std::uint32_t>(n); return u<=2147483647u?static_cast<int>(u):static_cast<int>(static_cast<std::int64_t>(u)-4294967296LL);};
 Point p{wrap(static_cast<std::int64_t>(s.x)+dx),wrap(static_cast<std::int64_t>(s.y)-dy)};
 s.t=static_cast<float>(s.t*2.0f);
 return p;
}
inline int roundScore(int turns) { int t=signedWord(static_cast<unsigned>(turns)); return t>8?5:((16-t)&65535); }
inline int displayedScore(int score) { return score*100; }
// _FillGunBox compares the SIGNED LOW BYTE! Scores 128..255 revert to 15.
inline int gunRadius(int score) {
 int low=score&255; if(low>=128) low-=256;
 return 15+5*std::min(5,std::max(0,low/15));
}
struct ScoreState { std::uint16_t score=0, remainder=0; };
// Returns whether the source would show LEVEL UP. This odd accumulated
// remainder test is preserved, rather than replaced with threshold crossing.
inline bool award(ScoreState& s,int turns) {
 s.score=static_cast<std::uint16_t>(s.score+roundScore(turns));
 if(signedWord(s.score)>=15 && signedWord(static_cast<unsigned>(turns))<=1) return true;
 s.remainder=static_cast<std::uint16_t>(s.remainder+s.score%15);
 if(signedWord(s.remainder)<15) return false;
 s.remainder=static_cast<std::uint16_t>(s.remainder-15); return true;
}
struct Random {
 std::uint16_t seed=0;
 std::uint16_t next(std::uint16_t exclusiveMax) {
  if(!exclusiveMax) throw std::invalid_argument("Random bound must be nonzero");
  seed=static_cast<std::uint16_t>((std::uint32_t(seed)*37549u+37747u)%65535u);
  return static_cast<std::uint16_t>(seed%exclusiveMax);
 }
};
struct Rect { int left,top,right,bottom; };
inline bool wordContains(Rect r,Point p) {
 auto u=[](int x){return static_cast<std::uint16_t>(x);};
 return u(p.x)>=u(r.left)&&u(p.x)<=u(r.right)&&u(p.y)>=u(r.top)&&u(p.y)<=u(r.bottom);
}
inline Rect blastBox(Point tank,int shape,int radius) {
 const int lo=shape==2?23:shape==5?10:11;
 return {tank.x+lo-radius,tank.y+lo-radius,
  tank.x+(shape==2?50:shape==5?45:41)+radius,
  tank.y+(shape==2?50:shape==5?45:43)+radius};
}
// Returns dead player 1/2, or 0. If both hitboxes overlap, player 1 dies first. Preserve the original P1-model typo in P2's model-5 check.
inline int hitPlayer(Point impact,int land,int p1model,int p2model,int radius) {
 if(land<0||land>=10) throw std::out_of_range("land");
 if(wordContains(blastBox(tankCoords[land][0],p1model,radius),impact)) return 1;
 int shape=p2model==2?2:p1model==5?5:1;
 return wordContains(blastBox(tankCoords[land][1],shape,radius),impact)?2:0;
}
enum class TraceKind { clear, hit, outOfBounds };
struct TraceResult { TraceKind kind; Point point; };
// Callbacks: pixel(Point)->uint32_t must read the live SCREEN including old
// white trail; draw(Point) writes white (only y<=397, original inclusive DestHeight bug).
// Bresenham omits endpoint, skips offscreen sky, and tests color before bottom
// bounds. A zero-length segment does nothing. _DrawBullet ASM 2292..2533.
// Coordinates are signed 16-bit inputs; arithmetic overflow beyond normal
// screen trajectories is deliberately not emulated (no DOS memory corruption).
template<class Pixel,class Draw>
TraceResult traceBullet(Point from,Point to,std::uint32_t sky,Pixel pixel,Draw draw) {
 from={signedWord(static_cast<unsigned>(from.x)),signedWord(static_cast<unsigned>(from.y))};
 to={signedWord(static_cast<unsigned>(to.x)),signedWord(static_cast<unsigned>(to.y))};
 int dx=std::abs(to.x-from.x),dy=std::abs(to.y-from.y);
 int sx=from.x<=to.x?1:-1,sy=from.y<=to.y?1:-1;
 bool horizontal=dx>=dy; int major=horizontal?dx:dy,minor=horizontal?dy:dx;
 int error=2*minor-major; Point p=from;
 for(int n=0;n<major;++n) {
  if(p.x==0||p.x==640) return {TraceKind::outOfBounds,p};
  if(wordContains({0,14,640,411},p)) {
   if(pixel(p)!=sky) return {TraceKind::hit,p};
   if(static_cast<unsigned>(p.y)<=13u||static_cast<unsigned>(p.y)>=410u) return {TraceKind::outOfBounds,p};
   if(p.x>=0&&p.x<640&&p.y>=0&&p.y<=397) draw(p);
  }
  if(error>=0) { p.x+=sx;p.y+=sy;error+=2*(minor-major); }
  else {if(horizontal)p.x+=sx;else p.y+=sy;error+=2*minor;}
 }
 return {TraceKind::clear,to};
}
struct Options { bool wind=false,sound=false; int rounds=5,color=5; std::uint32_t sky=0x234567; };
struct Player { ScoreState points; int angle=0,power=0,frame=0,model=1,radius=15; std::uint16_t turns=0; int wins=0; };
struct Game {
 Options options; Player players[2]; int land=0,turn=1,dead=0,winner=0,roundsRemaining=5;
 explicit Game(Options o={}) : options(o),roundsRemaining(o.rounds) {players[1].angle=180;players[1].frame=9;}
 void fired() {++players[turn-1].turns;}
 void switchTurn() {turn=3-turn;}
 int matchWinner() const {return players[0].wins>=players[1].wins?1:2;}
 bool finishRound(int deadPlayer) {
  if(deadPlayer<1||deadPlayer>2) throw std::out_of_range("dead player");
  dead=deadPlayer;winner=3-dead;auto& p=players[winner-1];++p.wins;--roundsRemaining;
  return award(p.points,p.turns);
 }
 void nextRound() {
  if(!dead||roundsRemaining<=0) return;
  turn=dead;dead=winner=0;++land;
  for(int i=0;i<2;++i) {auto& p=players[i];p.angle=i?180:0;p.frame=i?9:0;p.power=0;
   p.turns=static_cast<std::uint16_t>(p.turns&0xff00); // original resets only LOW BYTE
   p.radius=gunRadius(p.points.score);}
 }
};
} // namespace scorch
