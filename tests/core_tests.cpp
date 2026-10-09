#include "../src/core.hpp"
#include <iostream>
#include <vector>
#include <cstdlib>
using namespace scorch;
static int checks=0;
#define CHECK(...) do {++checks;if(!(__VA_ARGS__)) {std::cerr<<"FAIL line "<<__LINE__<<": "<<#__VA_ARGS__<<"\n";std::exit(1);}}while(false)
int main() {
 // Constants and muzzle offsets: ASM 101..152, 346..430.
 CHECK(tankCoords[0][0]==Point{105,224}); CHECK(tankCoords[9][1]==Point{447,224});
 CHECK(shotOrigin(0,1,1,0)==Point{165,249});CHECK(shotOrigin(9,2,6,9)==Point{452,251});
 CHECK(updateTankFrame(0,22)==1); CHECK(updateTankFrame(1,21)==1);
 CHECK(updateTankFrame(0,21)==0); CHECK(updateTankFrame(4,90)==4);
 // FINIT rounding: do not substitute std::round (ties away from zero).
 CHECK(nearestEven(0.5L)==0);CHECK(nearestEven(1.5L)==2);CHECK(nearestEven(2.5L)==2);
 CHECK(nearestEven(-0.5L)==0);CHECK(nearestEven(-1.5L)==-2);CHECK(nearestEven(-2.5L)==-2);
 // Original sample t doubles; y displacement is (vy - 5*t)*t, NOT -2.5*t*t.
 auto s=launch({100,200},100,0);CHECK(s.vx==100);CHECK(s.vy==0);
 const Point expected[]={{100,200},{100,200},{100,200},{101,200},{102,200},{103,200},
 {106,200},{113,200},{126,200},{151,201},{202,205},{305,221},{510,284},{919,536}};
 for(auto p:expected) CHECK(sample(s)==p);
 CHECK(s.x==100 && s.y==200); CHECK(s.t==0.001f*16384);
 auto vertical=launch({0,0},100,90);CHECK(vertical.vx>0.002f && vertical.vx<0.003f); CHECK(vertical.vy==100);
 Shot direct{100,200,10,20,1};CHECK(sample(direct)==Point{110,185});CHECK(direct.t==2);
 direct={100,200,10,20,1};CHECK(sample(direct,3)==Point{113,185});
 direct={100,200,10,20,1};CHECK(sample(direct,-3)==Point{113,185}); // FISUB signed word
 direct={100,200,10,20,1};CHECK(sample(direct,253)==Point{-143,185}); // commented wind generator format
 // Score units are hundreds on screen; discontinuity after eight attempts.
 CHECK(roundScore(0)==16);CHECK(roundScore(1)==15);CHECK(roundScore(8)==8);CHECK(roundScore(9)==5);
 CHECK(displayedScore(roundScore(1))==1500);
 CHECK(gunRadius(0)==15);CHECK(gunRadius(14)==15);CHECK(gunRadius(15)==20);
 CHECK(gunRadius(30)==25);CHECK(gunRadius(60)==35);CHECK(gunRadius(75)==40);
 CHECK(gunRadius(127)==40);CHECK(gunRadius(128)==15);CHECK(gunRadius(271)==20);
 ScoreState score;CHECK(!award(score,2));CHECK(score.score==14&&score.remainder==14);
 CHECK(award(score,2));CHECK(score.score==28&&score.remainder==12);
 ScoreState instant;CHECK(award(instant,0));CHECK(instant.score==16&&instant.remainder==0);
 Random rng;CHECK(rng.next(20)==7);CHECK(rng.seed==37747);
 CHECK(rng.next(20)==10);CHECK(rng.seed==8870);
 // Inclusive hit boxes, unsigned-word underflow, and P2 model-check typo.
 CHECK(hitPlayer({101,220},0,1,1,15)==1);CHECK(hitPlayer({100,220},0,1,1,15)==0);
 CHECK(hitPlayer({161,282},0,1,1,15)==1);
 CHECK(hitPlayer({10,175},2,1,1,15)==0); // wrapped left bound 65535!
 CHECK(hitPlayer({600,300},0,5,1,15)==2);CHECK(hitPlayer({600,300},0,1,5,15)==0);
 std::vector<Point> path;
 auto sky=[](Point){return 0x234567u;};auto draw=[&](Point p){path.push_back(p);};
 auto r=traceBullet({10,20},{13,21},0x234567,sky,draw);
 CHECK(r.kind==TraceKind::clear);CHECK(path.size()==3);
 CHECK(path[0]==Point{10,20});CHECK(path[1]==Point{11,20});CHECK(path[2]==Point{12,21});
 path.clear();traceBullet({10,20},{10,20},0x234567,sky,draw);CHECK(path.empty());
 r=traceBullet({1,20},{-1,20},0x234567,sky,draw);CHECK(r.kind==TraceKind::outOfBounds&&r.point==Point{0,20});
 r=traceBullet({10,10},{11,10},0x234567,sky,draw);CHECK(r.kind==TraceKind::clear);
 r=traceBullet({10,410},{10,412},0x234567,sky,draw);CHECK(r.kind==TraceKind::outOfBounds);
 auto solid=[](Point){return 0u;};
 r=traceBullet({10,410},{10,412},0x234567,solid,draw);CHECK(r.kind==TraceKind::hit);
 path.clear();traceBullet({10,398},{11,398},0x234567,sky,draw);CHECK(path.empty());
 Game game;CHECK(game.turn==1&&game.land==0&&game.roundsRemaining==5);
 CHECK(game.players[0].power==0&&game.players[1].angle==180&&game.players[1].frame==9);
 game.fired();CHECK(game.finishRound(2));CHECK(game.players[0].points.score==15);
 game.nextRound();CHECK(game.turn==2&&game.land==1&&game.players[0].radius==20);
 CHECK(game.players[0].turns==0&&game.players[0].power==0);
 std::cout<<checks<<" source-derived checks passed\n";
}
