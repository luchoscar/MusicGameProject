using UnityEngine;
using System.Collections;

public class StaticLevelScript : MonoBehaviour 
{
	bool debugging = false;
	
	public int collectables;
	public int level_idx;
	
	// Use this for initialization
	void Start () 
	{
		collectables = GameObject.FindGameObjectsWithTag("MusicNote").Length;
		
		GameObject.FindGameObjectWithTag("ground").renderer.material.SetFloat("_minDist", 0.5f);
	}
	
	// Update is called once per frame
	void Update () 
	{
		//if (debugging)
			Debug.Log(collectables);	
		
		if (collectables <= 0) StartCoroutine(LoadNextLevel());
	}
	
	void OnLevelWasLoaded(int level)
	{
		level_idx = level + 1;
		
		Debug.Log("This level " + level);
		Debug.Log("Next level " + level_idx);
		
		CollectableScript.dynamicLevel = false;
	}
	
	public IEnumerator LoadNextLevel()
	{
		Debug.Log("Static level builder call");
		
		yield return new WaitForSeconds(5);
		
		Debug.Log("Loading next level " + level_idx);
		
		Application.LoadLevel(level_idx);
	}
}
