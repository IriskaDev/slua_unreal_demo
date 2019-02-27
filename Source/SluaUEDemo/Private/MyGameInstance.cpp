// Fill out your copyright notice in the Description page of Project Settings.

#include "MyGameInstance.h"
#include "MyLuaStateMgr.h"

void UMyGameInstance::Init()
{
	Super::Init();
	UE_LOG(LogTemp, Warning, TEXT("Initiating Slua"));
	MyLuaStateMgr::GetMyLuaStateMgr().Init(this);
}

void UMyGameInstance::Shutdown()
{
	Super::Shutdown();
	UE_LOG(LogTemp, Warning, TEXT("Closing Slua"));
	MyLuaStateMgr::GetMyLuaStateMgr().Close();
}
