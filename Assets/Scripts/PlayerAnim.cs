/****************************************************
 * By Luis Saenz									*
 * Script to control player rotation when moving	*
 * 													*
 ****************************************************/

using UnityEngine;
using System.Collections;

public class PlayerAnim : MonoBehaviour 
{
	public bool debugging;
	
	int tiltDirection;
	int movementDir;
	
	float rad = 0.0f;
	float tiltRotation = 0.0f;
	float forwardRotation = 0.0f;
	
	public float MY_ZERO_VAL = 0.00000001f;
	//bool movingForward;
	//bool rotating;
	
	public float tiltRot;
	
	
	// Use this for initialization
	void Start () 
	{
		//movingForward = false;
		//rotating = false;
		
		rad = transform.localScale.z * 0.5f;
		
		if (rad < MY_ZERO_VAL)
		{
			Debug.Log("Player radius cannot be less than MY_ZERO_VAL (" + MY_ZERO_VAL + ")");
			rad = MY_ZERO_VAL;
		}
	}
	
	// Update is called once per frame
	void Update () 
	{
		//v = w * r --> w = v / r --> r = 0.5 --> w = v * 2.0
		transform.RotateAround(transform.position, transform.parent.right, forwardRotation * 2.0f * Time.deltaTime);
		transform.RotateAround(transform.position, transform.parent.forward, tiltRotation * 2.0f * Time.deltaTime);
		
		//draw rotation axis of playerObj (right vector)
		if (debugging)
			Debug.DrawRay(transform.position, transform.right * -5, Color.black);
		
		Debug.DrawRay(transform.parent.position, transform.parent.forward * 2.0f, Color.red);
	}
	
	public void AnimForward(float In_speed, int In_dir)
	{
		//make sure In_direction is normalize & not equal to zero
		if (In_dir != 0 && (In_dir != 1 || In_dir != -1))
		{
			In_dir /= Mathf.Abs(In_dir);
		}
		
		forwardRotation = In_speed * In_dir;
	}
	
	public void AnimSidways(int In_dir)
	{
		if (debugging)
			Debug.Log("Rot direction = " + In_dir);
		
		//make sure In_direction is normalize 
		if (In_dir != 0 && (In_dir != 1 || In_dir != -1))
		{
			In_dir /= Mathf.Abs(In_dir);
		}
		
		tiltRotation = tiltRot * In_dir;
	}
}
