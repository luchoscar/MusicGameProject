/************************************************************************************
 * By Luis Saenz,																	*
 * Script to setup velocity vector direction applied to player on collision			*
 * Applies velocity vector (dir * mag) to player when colliding 					*
 * Triggers object animation corresponding to this trigger							*
 * 																					*
 ************************************************************************************/

using UnityEngine;
using System.Collections;

public class RubberBoxTrigger : MonoBehaviour 
{
	public bool debugging;
	
	float pushMag;
	
	public int animIdx;
	public bool colliding = false;
	public Vector3 pushDirection;
	public Vector3 parentPos;
	
	public RubberBoxAnim boxAnimCmp;
	
	// Use this for initialization
	void Start () 
	{
		parentPos = transform.parent.position;
		parentPos.y = 0.0f;
		pushDirection = transform.position;
		parentPos.y = 0.0f;
		
		pushDirection -= parentPos;
		pushDirection = pushDirection.normalized;
		
		if (boxAnimCmp == null)
			boxAnimCmp = transform.parent.parent.GetComponent<RubberBoxAnim>();
		
		if (debugging)
			Debug.Log("Rubber push " + transform.parent.parent.GetComponent<RubberBoxAnim>().pushMag);
		
		pushMag = transform.parent.parent.GetComponent<RubberBoxAnim>().pushMag;
	}
	
	// Update is called once per frame
	void Update () 
	{
		if (debugging)
			Debug.DrawRay(transform.position, pushDirection * 2.0f, Color.red);
	}
	
	//collision --> apply force to player and play respective animation
	void OnTriggerEnter(Collider other) 
	{
        if (debugging)
			Debug.Log(other.name + " has entered collider " + transform.name);
		
		if (other.tag == "PlayerController" && !colliding)
		{
			if (debugging)
				Debug.Log(other.tag + " has entered collider");
			
			//play animation
			boxAnimCmp.PlayAnimation(animIdx);
			
			//apply force to player
			Debug.Log("Push mag " + pushMag);
			other.transform.GetComponent<PlayerMovement>().ApplyForceSpeed(pushMag, pushDirection);
			//other.transform.GetComponent<ThirdPersonController>().ApplyForceSpeed(pushMag, pushDirection);
		}
    }
	
	void OnTriggerExit(Collider other) 
	{
		if (colliding) colliding = !colliding;
	}
}
