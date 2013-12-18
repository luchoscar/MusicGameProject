/************************************************
 * By Luis Saenz								*
 * Script to start and stop playing music		*
 * 												*
 ************************************************/

using UnityEngine;
using System.Collections;

public class CameraSound : MonoBehaviour 
{
	public float MAX_TIMER = 5.0f;			//max time to play (seconds)
	float timer;							//timer variable
	static public bool playing;				//flag to indicate whether music is playing or not
	
	// Use this for initialization
	void Start () 
	{
		timer = 0.0f;
		CameraSound.playing = false;
	}
	
	// Update is called once per frame
	void Update () 
	{
		if (CameraSound.playing)
		{
			timer += Time.deltaTime;
			
			if (timer >= MAX_TIMER)
			{	
				PausePlaying();
			}
		}
	}
	
	//check whether music is playing to continue playing or start playing
	public void StartPlaying()
	{
		//only start playing if music has stopped
		if (!CameraSound.playing)
		{
			//wdaudio.Play();
		}
		
		//reset music variables
		CameraSound.playing = true;
		timer = 0.0f;
	}
	
	//pause music play
	public void PausePlaying()
	{
		audio.Pause();//.Stop();
		CameraSound.playing = false;
	}
}
