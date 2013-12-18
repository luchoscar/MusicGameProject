using UnityEngine;
using System.Collections;

public class WallScript : MonoBehaviour 
{
	public Transform playerLight;
	
	// Use this for initialization
	void Start () 
	{
		playerLight = GameObject.FindGameObjectWithTag("PlayerController").transform;
		renderer.material.SetFloat("lightRange", GameObject.FindGameObjectWithTag("playerLight").transform.light.range);
	}
	
	// Update is called once per frame
	void Update () 
	{
	
	}
	
	void LateUpdate()
	{
		renderer.material.SetVector("lightPos", playerLight.position);
		renderer.material.SetFloat("_LightInt", playerLight.GetChild(1).light.intensity);
	}
}
