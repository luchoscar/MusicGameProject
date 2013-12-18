using UnityEngine;
using System.Collections;

public class LevelManager : MonoBehaviour 
{

	// Use this for initialization
	void Awake () 
	{
		DontDestroyOnLoad (transform.gameObject);

		LevelLoader.InitGame();
	}
}
