/****************************************************************
 * By Luis Saenz												*
 * Script to make camera follow player from a set distance		*
 * 																*
 ****************************************************************/

using UnityEngine;
using System.Collections;

public class CameraScript : MonoBehaviour 
{
	bool debugging;
	
	public static float yOffset = 3.0f;				//y-offset from the player
	public static float xzDist = 12.50f;					//offset on xz-plane
	public Transform target;					//object to look at
	
	public float heightDamp = 2.0f;			//speed of rotation adjustment
	public float rotationDamp = 3.0f;		//speed of height adjustment
	
	// Use this for initialization
	void Start () 
	{
		if (target == null)
			target = GameObject.FindGameObjectWithTag("PlayerController").transform;
	}
	
	// Update is called once per frame
	void LateUpdate () 
	{
		//get camera & target rotation and y-pos
		float destRot = target.eulerAngles.y;
		float destHeight = target.position.y + yOffset;
		
		float currentRot = transform.eulerAngles.y;
		float currentHeight = transform.position.y;
		
		//adjust variables to hold new y-pos & y-angle
		if (Vector3.Dot(target.forward, Vector3.up) <= Mathf.Cos(45.0f * Mathf.Deg2Rad))
		{
			currentRot = Mathf.LerpAngle(currentRot, destRot, rotationDamp * Time.deltaTime);
			currentHeight = Mathf.Lerp(currentHeight, destHeight, heightDamp * Time.deltaTime);
		}
		
		//adjust camera rotation and position & look at player
		Quaternion finalRotation = Quaternion.Euler(0.0f, currentRot, 0.0f);
		transform.position = target.position;
		transform.position -= finalRotation * Vector3.forward * xzDist;
		
		Vector3 tempLoc = new Vector3(transform.position.x, currentHeight, transform.position.z);
		transform.position = tempLoc;
		
		transform.LookAt(target);
	}
}
