

#include "MyLuaStateMgr.h"
#include "HAL/PlatformFileManager.h"
#include "Misc/Paths.h"
#include "GenericPlatformFile.h"
#include "Engine/Engine.h"
#include "HAL/FileManager.h"
#include "CppInterface.h"
#include "LuaState.h"
#include "MyGameInstance.h"
#include "TimerManager.h"

static uint8* ReadFile(IPlatformFile& PlatformFile, FString path, uint32& len) 
{
	IFileHandle* FileHandle = PlatformFile.OpenRead(*path);
	if (FileHandle) 
	{
		len = (uint32)FileHandle->Size();
		uint8* buf = new uint8[len];
		FileHandle->Read(buf, len);

		// Close the file again
		delete FileHandle;
		return buf;
	}
	return nullptr;
}

MyLuaStateMgr::MyLuaStateMgr()
	: _state("mystate"), _initialized(false)
{

}

MyLuaStateMgr::~MyLuaStateMgr()
{
	_state.close();
	_initialized = false;
}

MyLuaStateMgr & MyLuaStateMgr::GetMyLuaStateMgr()
{
	static MyLuaStateMgr _myLuaStateMgr;
	return _myLuaStateMgr;
}

int MyLuaStateMgr::Init(UMyGameInstance* instance)
{
	_instance = instance;

	if (_initialized)
		return 0;

	bool initok = _state.init();
	if (!initok)
	{
		return 1;
	}
	_state.setLoadFileDelegate([](const char* fn, uint32& len, FString& filepath) -> uint8* {
		IPlatformFile & platformFile = FPlatformFileManager::Get().GetPlatformFile();
		FString path = FPaths::ProjectContentDir();
		path += "/Lua/";
		path += UTF8_TO_TCHAR(fn);
		TArray<FString> luaExts = { UTF8_TO_TCHAR(".lua"), UTF8_TO_TCHAR(".luac") };
		for (auto &it : luaExts)
		{
			auto fullPath = path + *it;
			auto buf = ReadFile(platformFile, fullPath, len);
			if (buf)
			{
				fullPath = IFileManager::Get().ConvertToAbsolutePathForExternalAppForRead(*fullPath);
				filepath = fullPath;
				return buf;
			}
		}
		return nullptr;
	});

	CppInterface::OpenLib(_state);

	_initialized = true;
	return 0;
}

int MyLuaStateMgr::Close()
{
	if (!_initialized)
		return 1;
	_state.close();
	_initialized = false;
	ClearAllTimers();
	return 0;
}

UMyGameInstance * MyLuaStateMgr::GetMyGameInstance()
{
	return _instance;
}

int MyLuaStateMgr::SetTimer(float interval, bool looping, void * func)
{
	slua::LuaVar *f = (slua::LuaVar*) func;
	FTimerDelegate timerDelegate;
	timerDelegate.BindLambda([](slua::LuaVar*func) {if (func) func->call(); }, f);
	FTimerHandle handler;
	_instance->GetTimerManager().SetTimer(handler, timerDelegate, interval, looping);
	++_timerindex;
	_timers.Add(_timerindex, handler);
	return _timerindex;
}

int MyLuaStateMgr::ClearTimer(int idx)
{
	if (!_timers.Contains(idx))
		return 0;

	FTimerHandle handler = _timers[idx];
	_timers.Remove(idx);
	_instance->GetTimerManager().ClearTimer(handler);
	return 0;
}

int MyLuaStateMgr::ClearAllTimers()
{
	for (TPair<int, FTimerHandle> it : _timers)
	{
		_instance->GetTimerManager().ClearTimer(it.Value);
	}
	_timers.Empty();
	_timerindex = 0;
	return 0;
}
