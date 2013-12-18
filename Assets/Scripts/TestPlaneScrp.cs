using UnityEngine;
using System.Collections;

public class TestPlaneScrp : MonoBehaviour 
{
	public Transform playerObj;
	public Light mainLight;
	
	// Use this for initialization
	void Start () 
	{
		if (playerObj == null)
			playerObj = GameObject.FindGameObjectWithTag("Player").transform;
		
//		if (mainLight == null)
//			mainLight = GameObject.FindGameObjectWithTag("MainLight").light;
	}
	
	// Update is called once per frame
	void Update () 
	{
		transform.up = Vector3.up;
	}
	
	void LateUpdate()
	{
//		renderer.material.SetVector("playerPos", renderer.worldToLocalMatrix.MultiplyPoint(playerObj.position));
//		renderer.material.SetVector("playerFwd", renderer.worldToLocalMatrix.MultiplyVector(playerObj.parent.forward));
		renderer.material.SetVector("playerPos", playerObj.position);
		renderer.material.SetVector("playerFwd", renderer.worldToLocalMatrix.MultiplyVector(playerObj.parent.forward));
		//renderer.material.SetVector("lightPos", playerObj.position);
	}
}
