using UnityEngine;
using System.Collections;

public class TreeWind : MonoBehaviour 
{
	public Light mainLight;
	public Vector3 windDir;
	public float windForce;
	public float angle;
	public int dir;
	
	// Use this for initialization
	void Start () 
	{
		
	}
	
	// Update is called once per frame
	void Update () 
	{
		if (Input.GetKey(KeyCode.Q))
		{
			windDir = Random.insideUnitSphere;
			windDir *= windForce;
		}
		
		angle += Time.deltaTime * dir;
		
		if (angle >= 2.0f * Mathf.PI)
		{
			angle = 2.0f * Mathf.PI;
			dir = -1;
		}
		else if (angle <= 0.0f)
		{
			angle = 0.0f;
			dir = 1;
		}
		
		transform.renderer.materials[0].SetFloat("_BendOffset", Mathf.Log(angle));
//		transform.renderer.materials[0].SetFloat("_BendOffset", angle * angle);
	}
}
