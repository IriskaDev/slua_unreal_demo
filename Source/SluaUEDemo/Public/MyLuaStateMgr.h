#ifndef ___MY_LUASTATE_MGR_H___
#define ___MY_LUASTATE_MGR_H___

#include "LuaState.h"
#include "MyGameInstance.h"

//class UMyGameInstance;

class MyLuaStateMgr 
{
public:
	MyLuaStateMgr();
	~MyLuaStateMgr();

	static MyLuaStateMgr & GetMyLuaStateMgr();
	int Init(UMyGameInstance*);
	int Close();
	UMyGameInstance * GetMyGameInstance();
	int SetTimer(float invterval, bool looping, void * func);
	int ClearTimer(int idx);
	int ClearAllTimers();

private:
	slua::LuaState _state;
	UMyGameInstance * _instance;
	bool _initialized;
	TMap<int, FTimerHandle> _timers;
	int _timerindex;
};

#endif
