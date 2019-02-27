#include "CppInterface.h"
#include "lauxlib.h"
#include "HeadMountedDisplayFunctionLibrary.h"
#include "Kismet/GameplayStatics.h"
#include "LuaObject.h"
#include "TimerManager.h"
#include "MyLuaStateMgr.h"


/*
#1 interval
#2 looping
#3 callback
*/
int SetTimer(slua::lua_State *L)
{
	float interval = slua::LuaObject::checkValue<float>(L, 1);
	bool looping = slua::LuaObject::checkValue<bool>(L, 2);
	slua::LuaVar *func = new slua::LuaVar(L, 3, slua::LuaVar::LV_FUNCTION);

	MyLuaStateMgr & mgr = MyLuaStateMgr::GetMyLuaStateMgr();
	int idx = mgr.SetTimer(interval, looping, func);
	return slua::LuaObject::push(L, idx);
}

int ClearTimer(slua::lua_State *L)
{
	int idx = slua::LuaObject::checkValue<int>(L, 1);
	MyLuaStateMgr & mgr = MyLuaStateMgr::GetMyLuaStateMgr();
	mgr.ClearTimer(idx);
	return 0;
}

static slua::luaL_Reg cppInterfaceMethods[] = {
	{"SetTimer",						SetTimer},
	{"ClearTimer",						ClearTimer},
	{NULL, NULL},
};

void create_table(slua::lua_State* L, slua::luaL_Reg* funcs)
{
	lua_newtable(L);									// t

	for (; funcs->name; ++funcs)
	{
		lua_pushstring(L, funcs->name);					// t, func_name
		lua_pushcfunction(L, funcs->func);				// t, func_name, func
		lua_rawset(L, -3);								// t
	}

	lua_setglobal(L, "CppInterface");					// 
}

int CppInterface::OpenLib(slua::lua_State* L)
{
	create_table(L, cppInterfaceMethods);
	return 0;
}

