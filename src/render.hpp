#pragma once
#include <cstdint>
#include <vector>
#include <string>
#include <algorithm>
#include <fstream>
namespace scorch {
struct Image { int w=0,h=0; std::vector<uint32_t> pixels; Image()=default; Image(int W,int H,uint32_t c=0):w(W),h(H),pixels(W*H,c){} uint32_t get(int x,int y) const {return x>=0&&y>=0&&x<w&&y<h?pixels[y*w+x]:0;} void put(int x,int y,uint32_t c){if(x>=0&&y>=0&&x<w&&y<h)pixels[y*w+x]=c;} };
inline uint32_t compose(uint32_t s,uint32_t d){uint32_t r=0,a=s>>24;for(int n=0;n<32;n+=8){int S=(s>>n)&255,D=(d>>n)&255;int rounding=n==24?0:128;int c=((S*a+rounding)>>8)+D-((D*a+rounding)>>8);r|=uint32_t(std::clamp(c,0,255))<<n;}return r;}
inline void blit(Image& d,const Image& s,int x,int y,int sx=0,int sy=0,int w=-1,int h=-1,bool alpha=false){if(w<0)w=s.w;if(h<0)h=s.h;for(int j=0;j<h;j++)for(int i=0;i<w;i++){if(i+sx<0||j+sy<0||i+sx>=s.w||j+sy>=s.h)continue;auto c=s.get(i+sx,j+sy);d.put(x+i,y+j,alpha?compose(c,d.get(x+i,y+j)):c);}}
inline void dim(Image& d,uint32_t color=0xa0000000){for(auto& p:d.pixels)p=compose(color,p);}
inline void rect(Image& d,int x,int y,int x2,int y2,uint32_t c,bool fill=false){for(int j=y;j<=y2;j++)for(int i=x;i<=x2;i++)if(fill||j==y||j==y2||i==x||i==x2)d.put(i,j,c);}
inline void flood(Image& d,int x,int y,uint32_t c){auto old=d.get(x,y);if(old==c||x<0||y<0||x>=d.w||y>=d.h)return;std::vector<int> q{y*d.w+x};d.put(x,y,c);while(!q.empty()){int n=q.back();q.pop_back();int X=n%d.w,Y=n/d.w;int dx[]={-1,1,0,0},dy[]={0,0,-1,1};for(int i=0;i<4;i++){int a=X+dx[i],b=Y+dy[i];if(a>=0&&b>=0&&a<d.w&&b<d.h&&d.get(a,b)==old){d.put(a,b,c);q.push_back(b*d.w+a);}}}}
inline void circle(Image& d,int X,int Y,int r,uint32_t c,bool filled){int x=0,y=r,e=1-r;auto p=[&](int a,int b){if(b>=14&&b<=411)d.put(a,b,c);};while(x<=y){p(X+x,Y+y);p(X-x,Y+y);p(X+x,Y-y);p(X-x,Y-y);p(X+y,Y+x);p(X-y,Y+x);p(X+y,Y-x);p(X-y,Y-x);++x;if(e<0)e+=2*x+1;else {--y;e+=2*(x-y)+1;}}if(filled&&r>0)flood(d,X,Y,c);}
inline void text(Image& d,const Image& font,const std::string& t,int x,int y,uint32_t color=0xffffff){for(unsigned char c:t){if(c==';'){x+=13;continue;}rect(d,x,y,x+15,y+15,0xff000000,true);if(c!=' ')for(int j=0;j<16;j++)for(int i=0;i<16;i++){uint32_t s=(font.get(c*16+i,j)&0xff000000)|(color&0xffffff);d.put(x+i,y+j,compose(s,d.get(x+i,y+j)));}x+=13;}}
inline void saveBMP(const Image& a,const std::string& path){std::ofstream f(path,std::ios::binary);uint32_t sz=54+a.w*a.h*4,off=54,head=40,zero=0;uint16_t one=1,bpp=32;int32_t w=a.w,h=-a.h;f.write("BM",2);f.write((char*)&sz,4);f.write((char*)&zero,4);f.write((char*)&off,4);f.write((char*)&head,4);f.write((char*)&w,4);f.write((char*)&h,4);f.write((char*)&one,2);f.write((char*)&bpp,2);for(int i=0;i<6;i++)f.write((char*)&zero,4);f.write((char*)a.pixels.data(),a.pixels.size()*4);}
}
