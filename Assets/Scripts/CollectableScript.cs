/****************************************************************
 * By Luis Saenz												*
 * Script to track when a player collects an object 			*
 * It calls camera function to start playing music				*
 * 																*
 ****************************************************************/


using UnityEngine;
using System.Collections;

public class CollectableScript : MonoBehaviour 
{
	private AudioClip soundEfect;

	public bool debugging = false;

	public static bool dynamicLevel;
	
	public int index = -1;
	static public float collectTimer;
	float MAX_TIME = 15.0f;
	static public bool startCount = false;
	
	// Use this for initialization
	void Start () 
	{
		soundEfect = GameObject.FindGameObjectWithTag ("randomNote").GetComponent<RandomSound> ().GetRandomeNote (0, 36);
	}
	
	// Update is called once per frame
	void Update () 
	{
		if (CollectableScript.startCount)
		{
			CollectableScript.collectTimer += Time.deltaTime;
			
			if (CollectableScript.collectTimer >= MAX_TIME)
			{
				CollectableScript.collectTimer = 0.0f;
				CollectableScript.startCount = false;
				animation.Stop();
			}
			
			if (debugging)
				Debug.Log (CollectableScript.collectTimer);
		}
	}
	
	void OnTriggerEnter(Collider other) 
	{
		Camera.main.audio.clip = soundEfect;
		Camera.main.audio.Play ();

		if (CollectableScript.dynamicLevel)
		{
			if (!CollectableScript.startCount) 
			{
				CollectableScript.startCount = true;
				//animation.Play();
			}
		}
		else
		{
			GameObject.FindGameObjectWithTag("staticLevelCntrl").GetComponent<StaticLevelScript>().collectables--;
		}
		
		animation.Play();
		CollectableScript.collectTimer = 0.0f;
		
		Camera.main.transform.GetComponent<CameraSound>().StartPlaying();
		LevelBuilder.collectTotal--;
		
		//to destroy object implement a shader to fade away and then destroy the object
		Destroy (this.gameObject);
	}
}
