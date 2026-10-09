// Exercise the actual application state machine, not a second implementation.
#define SCORCH_APP_TEST
#include "../src/main.cpp"
#include <iostream>
int checks=0;
void check(bool ok,const char* what){++checks;if(!ok)throw std::runtime_error(what);}
int main(){
 CoInitializeEx(nullptr,COINIT_APARTMENTTHREADED);
 try {
 App a(std::filesystem::path(SCORCH_ASSET_ROOT));
 a.key(VK_RETURN);check(a.screen==Screen::Menu,"intro skip");
 a.key(VK_UP);check(a.menu==3,"menu up wrap");a.key(VK_DOWN);
 a.key(VK_DOWN);a.key(VK_RETURN);check(a.screen==Screen::Options,"options entry");
 a.key(VK_RIGHT);check(a.editing.wind&&!a.options.wind,"options transactional");
 a.key(VK_ESCAPE);check(a.screen==Screen::Options,"escape not source option key");
 a.key('Q');check(a.screen==Screen::Menu&&a.menu==0&&!a.options.wind,"discard and reset menu");
 a.key(VK_DOWN);a.key(VK_RETURN);a.key(VK_DOWN);a.key(VK_DOWN);a.key(VK_LEFT);
 a.key(VK_DOWN);a.key(VK_LEFT);a.key(VK_DOWN);a.key(VK_RETURN);
 check(a.options.rounds==3&&a.options.color==4&&a.options.sky==0x408080&&a.menu==0,"save options");
 a.key(VK_DOWN);a.key(VK_DOWN);a.key(VK_RETURN);a.key(VK_ESCAPE);
 check(a.screen==Screen::Help,"credits requires enter");a.key(VK_RETURN);
 check(a.screen==Screen::Menu&&a.menu==0,"credits resets menu");a.key(VK_RETURN);
 a.key(VK_LEFT);check(a.selection==2,"tank left wrap");a.key(VK_DOWN);check(a.selection==5,"tank row toggle");
 a.key(VK_RETURN);a.character('A');a.character('a');a.character(' ');
 check(a.names[0]=="a ","player one alphabet and space");a.names[0]="ab";a.render();Image actual=a.frame;a.tankScreen();a.modal("namemenu.png",true);a.label("a",237,264);a.label("b",251,264);check(a.frame.pixels==actual.pixels,"name glyphs advance fourteen pixels");a.names[0]="a ";a.key(VK_BACK);a.key(VK_RETURN);
 a.key(VK_RETURN);a.character('b');a.character(' ');check(a.names[1]=="b","player two disallows space");
 for(int i=0;i<12;i++)a.character('c');check(a.names[1].size()==10,"name length");a.key(VK_RETURN);
 check(a.screen==Screen::Play&&a.game.players[0].model==6,"setup to game");
 a.key(VK_ESCAPE);check(a.screen==Screen::Play,"escape not gameplay quit");
 a.key(VK_F1);a.key(VK_ESCAPE);check(a.screen==Screen::Help,"help enter only");a.key(VK_RETURN);
 a.key('Q');a.key('N');check(a.screen==Screen::Play,"cancel quit");
 a.key('Q');a.render();Image confirm=a.frame;a.key('Y');a.render();
 check(a.frame.get(10,10)==confirm.get(10,10),"exit choice preserves dim background");a.key('M');
 check(a.screen==Screen::Menu&&a.menu==0,"quit to menu");
 a.newMatch();a.key(VK_UP);a.key(VK_RIGHT);check(a.game.players[0].angle==1&&a.game.players[0].power==1,"aim controls");
 a.key(VK_RETURN);int angle=a.game.players[0].angle;a.key(VK_UP);check(a.game.players[0].angle==angle,"input ignored during shot");
 for(int i=0;i<2000&&a.shooting;i++)a.update(.016);check(!a.shooting,"shot terminates");
 a.newMatch();for(int i=0;i<3;i++){a.game.fired();a.level=a.game.finishRound(i%2+1);a.screen=Screen::Round;a.render();Image round=a.frame;a.key(VK_RETURN);if(i==2){a.render();check(a.frame.get(10,10)==compose(0xa0000000,round.get(10,10)),"match dims prior round overlay");}}
 check(a.screen==Screen::Match,"full match");a.key(VK_RETURN);a.render();Image prompt=a.frame;a.key('N');a.render();
 check(a.frame.get(10,10)==prompt.get(10,10),"post-match exit keeps match background");
 a.screen=Screen::NewGame;a.key('Y');check(a.screen==Screen::Play&&a.game.land==0&&a.game.players[0].points.score==0,"restart clears match");
 // Collision must wait five ticks from contact, not from previous trajectory sample.
 a.shooting=true;a.screen=Screen::Play;a.shotPhase=0;a.shotClock=0;a.previous={100,100};a.shot={100,100,1000,0,.001f};a.field=Image(640,480,0);a.options.sky=1;
 a.update(.06);check(a.shotPhase==1&&a.shotClock==0,"contact starts fresh impact delay");a.update(.274);check(a.radius==0,"impact waits five ticks");a.update(.002);check(a.radius==1,"impact starts after delay");
 std::cout<<checks<<" native application checks passed\n";
 CoUninitialize();return 0;
 }catch(const std::exception& e){std::cerr<<e.what()<<'\n';CoUninitialize();return 1;}
}
