using UnityEngine;
using System.Collections;

public class RimLightScript : MonoBehaviour {
	
	// Use this for initialization
	void Start () 
	{
		
	}
	
	// Update is called once per frame
	void Update () {
	
	}
	
	void LateUpdate()
	{
		renderer.material.SetVector("eyePos", Camera.main.transform.position);
		renderer.material.SetVector("lightPos", GameObject.FindGameObjectWithTag("PlayerController").transform.position);
	}
}
