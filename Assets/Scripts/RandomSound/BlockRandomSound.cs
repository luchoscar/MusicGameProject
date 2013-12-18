using UnityEngine;
using System.Collections;

public class BlockRandomSound : MonoBehaviour {

	public AudioClip soundEfect;
	public int beginSoundIdx, endSoundIdx;

	// Use this for initialization
	void Start () {
		switch (transform.tag) 
		{
		case "cube":
			beginSoundIdx = 12;
			endSoundIdx = 23;
			break;
		case "tube":
			beginSoundIdx = 24;
			endSoundIdx = 35;
			break;
		default:
			break;
		}

		soundEfect = GameObject.FindGameObjectWithTag ("randomNote").GetComponent<RandomSound> ().GetRandomeNote (beginSoundIdx, endSoundIdx);
	}
	
	// Update is called once per frame
	void Update () {
	
	}

	void OnCollisionEnter(Collision collision)
	{
		Debug.Log (collision.transform.tag);
		Debug.Log ("colliding");
		if (collision.transform.tag == "playerHolder")
		{
			Camera.main.audio.clip = soundEfect;
			Camera.main.audio.Play ();
		}
	}
}
