#pragma once
#define NOMINMAX
#include <windows.h>
#include <wincodec.h>
#include <mmsystem.h>
#include <filesystem>
#include <map>
#include <stdexcept>
#include <thread>
#include "render.hpp"
namespace scorch {
inline Image loadPNG(const std::filesystem::path& path){IWICImagingFactory* f=nullptr;IWICBitmapDecoder* d=nullptr;IWICBitmapFrameDecode* b=nullptr;IWICFormatConverter* c=nullptr;Image result;HRESULT hr=CoCreateInstance(CLSID_WICImagingFactory,nullptr,CLSCTX_INPROC_SERVER,IID_PPV_ARGS(&f));if(SUCCEEDED(hr))hr=f->CreateDecoderFromFilename(path.c_str(),nullptr,GENERIC_READ,WICDecodeMetadataCacheOnLoad,&d);if(SUCCEEDED(hr))hr=d->GetFrame(0,&b);if(SUCCEEDED(hr))hr=f->CreateFormatConverter(&c);if(SUCCEEDED(hr))hr=c->Initialize(b,GUID_WICPixelFormat32bppBGRA,WICBitmapDitherTypeNone,nullptr,0,WICBitmapPaletteTypeCustom);UINT w=0,h=0;if(SUCCEEDED(hr))hr=c->GetSize(&w,&h);if(SUCCEEDED(hr)){result=Image(w,h);hr=c->CopyPixels(nullptr,w*4,w*h*4,reinterpret_cast<BYTE*>(result.pixels.data()));}if(c)c->Release();if(b)b->Release();if(d)d->Release();if(f)f->Release();if(FAILED(hr))throw std::runtime_error("Cannot decode asset: "+path.string());return result;}
struct Assets {std::filesystem::path root;std::map<std::string,Image> images;const Image& get(const std::string& name){auto it=images.find(name);if(it==images.end())it=images.emplace(name,loadPNG(root/name)).first;return it->second;} };
struct Note{unsigned divisor,ticks;};
// PIT square-wave synthesis through native waveOut. No DOS I/O or emulation.
inline void playNotes(std::vector<Note> notes){std::thread([notes=std::move(notes)]{constexpr int rate=22050;std::vector<int16_t> pcm;for(auto n:notes){int count=int(n.ticks*65536.0/1193182.0*rate);double freq=1193182.0/(n.divisor?n.divisor:65536);for(int i=0;i<count;i++)pcm.push_back(n.divisor==1?0:((int(i*freq*2/rate)&1)?3500:-3500));}WAVEFORMATEX fmt{};fmt.wFormatTag=WAVE_FORMAT_PCM;fmt.nChannels=1;fmt.nSamplesPerSec=rate;fmt.wBitsPerSample=16;fmt.nBlockAlign=2;fmt.nAvgBytesPerSec=rate*2;HWAVEOUT out;if(waveOutOpen(&out,WAVE_MAPPER,&fmt,0,0,CALLBACK_NULL)!=MMSYSERR_NOERROR)return;WAVEHDR h{};h.lpData=(LPSTR)pcm.data();h.dwBufferLength=DWORD(pcm.size()*2);waveOutPrepareHeader(out,&h,sizeof h);waveOutWrite(out,&h,sizeof h);while(!(h.dwFlags&WHDR_DONE))Sleep(10);waveOutUnprepareHeader(out,&h,sizeof h);waveOutClose(out);}).detach();}
inline void firingSound(){std::vector<Note> n;for(int i=0;i<8;i++)n.push_back({unsigned((1320-i*400)&65535),1});playNotes(n);}
inline void impactSound(){std::vector<Note> n;for(int i=0;i<6;i++){n.push_back({6220,1});n.push_back({4600,1});}playNotes(n);}
inline void battleHymn(){playNotes({{6087,8},{1,2},{6087,4},{1,2},{6087,8},{1,2},{6833,4},{1,2},{7239,8},{1,2},{6087,4},{1,2},{4560,8},{1,2},{4063,4},{1,2},{3619,8},{1,2},{3619,4},{1,2},{3619,8},{1,2},{4063,4},{1,2},{4560,12}});}
}
