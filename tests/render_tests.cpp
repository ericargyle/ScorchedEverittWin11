#include "../src/render.hpp"
#include "../src/intro.hpp"
#include <iostream>
#include <stdexcept>
void check(bool ok){if(!ok)throw std::runtime_error("renderer regression");}
int main(){using namespace scorch;check((compose(0x10000000,0xffffffff)&255)==239);Image a(20,20,0);rect(a,2,2,10,10,0xffffff);flood(a,3,3,0xff00);check(a.get(3,3)==0xff00);check(a.get(0,0)==0);check(introFrames(0).empty());check(introFrames(introPauseSeconds+.001)[0].asset=="intro/2.png");auto f=introFrames(introDuration-.001);check(f.size()==41);check(f[0].asset=="intro/P.png");check(introFrames(introDuration).empty());check(introFadeChannel(255)==239);std::cout<<"9 renderer/intro checks passed\n";}
