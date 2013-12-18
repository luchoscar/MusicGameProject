using UnityEngine;
using System.Collections;

/// <summary>
/// Level loader.
/// Handle level loading based on current level id
/// </summary>
public static class LevelLoader 
{
	public static int level_idx = 0;
	
	// Use this for initialization
	public static void InitGame()
	{
		LevelLoader.level_idx = 0;
	}
	
	public static void LoadNextScene()
	{
		LevelLoader.level_idx++;
		
		Application.LoadLevel(level_idx);
	}
}
