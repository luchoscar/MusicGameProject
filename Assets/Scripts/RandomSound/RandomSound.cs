using UnityEngine;
using System.Collections;

public class RandomSound : MonoBehaviour {

	public AudioClip [] audioArray;

	void Awake()
	{
		DontDestroyOnLoad (this.gameObject);
	}

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
	
	}

	public AudioClip GetRandomeNote(int from, int to)
	{
		int idx = Random.Range (from, to);
		return audioArray [idx];
	}
}
