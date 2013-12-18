/************************************************************************************
 * By Luis Saenz,																	*
 * Script to control player behavior: regular movement and applied forces			*				
 * Implements build in script "CharacterController" to track collision flags 		*
 * around player during movement													*
 * 																					*
 ************************************************************************************/

using UnityEngine;
using System.Collections;

[RequireComponent (typeof (CharacterController))]

public class PlayerMovement : MonoBehaviour 
{
	public bool debugging;
	
	//*** private variables *******************************************************************************************
	//public bool[] inputBuffer = new bool[4];	//input buffer of 4 flags: 0 -> front(W), 1 -> back(S), 2 -> left(A), 3 -> right(D)
	int fwdDir;										//flag indicating whether player is accelerating or slowing down
	int sidDir;										//flag indicating whether player is rotating left or right
		
	PlayerAnim playerObj;							//player
	float verticalSpeed;							//speed y-direction
	public bool applyAirFriction = false;					//flag indicating when to slow down player after applying force
	Vector3 movementDir;							//direction of movement
	public float externalSpeed;							//speed applied by rubber obj
	float walkingSpeed;								//speed when pressing a key
	float rotationSpeed;							//angle speed of rotation
	
	CollisionFlags c_collisionFlags;				//collision flag from movement
	
	//*** public variables ********************************************************************************************
	public float movementSpeed;						//speed of linear movement (xz-plane)
	public static float ZERO = 0.001f;				//value to take as reference for 0.0 --> between 0.001 & -0.001
	public CharacterController controller;			//character controller component
	public float linearAcc = 150.0f;
	public float spinAcc = 50.0f;
	public float maxFwdSpeed = 100.0f;
	public float jumpSpeed = 10.0f;					//speed of jump
	public float gravity = 20.0f;					//gravity magnitud y-axis
	public float externalForceFrict = 0.005f;		//friction applied to external force
	
	//*** unity functions *********************************************************************************************
	// Use this for initialization
	void Awake()
	{
		//attach script to main camera
		if (Camera.main.gameObject.transform.GetComponent<CameraScript>() == null)
			Camera.main.gameObject.AddComponent<CameraScript>();
	}
	
	void Start () 
	{
		/*
		//set all inputs to false
		for(int i = 0; i < inputBuffer.Length; i++)
		{
			inputBuffer[i] = false;	
		}
		*/
			
		//get player object
		if (playerObj == null)
			playerObj = GameObject.FindGameObjectWithTag("Player").transform.GetComponent<PlayerAnim>();
		
		//get controler for movement and collision flags
		if (controller == null)
			controller = transform.GetComponent<CharacterController>();
		
		c_collisionFlags = CollisionFlags.CollidedBelow;
		
		//set movement variables
		movementDir = transform.forward;
		movementSpeed = 0.0f;
		//spinSpeed = 0.0f;
		verticalSpeed = 0.0f;		
	}
	
	// Update is called once per frame
	void Update () 
	{
		sidDir = 0;
			
		//getting player's input
		if(Input.GetKey(KeyCode.W))
		//if(inputBuffer[0])
		{			
			if (debugging)
				Debug.Log("moving forward");
			
			walkingSpeed += linearAcc * Time.deltaTime;	//walkingSpeed
			
			if (walkingSpeed >= maxFwdSpeed)
				walkingSpeed = maxFwdSpeed;
			
			fwdDir = 1;
		}
		if(Input.GetKey(KeyCode.A))
		{
			transform.Rotate(Vector3.up * -spinAcc * Time.deltaTime); //rotationSpeed
			sidDir = 1;
		}
		if(Input.GetKey(KeyCode.D))
		{
			transform.Rotate(Vector3.up * spinAcc * Time.deltaTime); //rotationSpeed
			sidDir = -1;
		}
		if(Input.GetKey(KeyCode.S))
		{
			if (debugging)
				Debug.Log("moving baclwards");
			
			if (walkingSpeed > 0.0f)
				walkingSpeed -= linearAcc * Time.deltaTime;
			else
				walkingSpeed = 0.0f;
			
			
			if (externalSpeed > 0.0f && applyAirFriction)
				externalSpeed -= linearAcc * Time.deltaTime;
			else
				externalSpeed = 0.0f;
			
			fwdDir = -1;
		}
				
		//checking if force has been applied
		if (applyAirFriction && externalSpeed > 0.0f)
		{
			if (debugging)
				Debug.Log("applying friction");
			
			externalSpeed -= externalForceFrict;
		}
		else
		{
			//Debug.Log("No more external force");
			externalSpeed = 0.0f;
			applyAirFriction = false;
		}
		
		
		//calculate speed direction and magnitud
		movementSpeed = walkingSpeed + externalSpeed;
		movementDir = movementSpeed * transform.forward * Time.deltaTime;
		
		//rotate spehere when moving forward & sideways
		if (movementSpeed > 0.0f)
		{
			playerObj.AnimForward(movementSpeed, fwdDir);
		}
		
		playerObj.AnimSidways(sidDir);
		
		
		//check if player is on the air 
		if (!IsGrounded())
		{
			verticalSpeed -= gravity * Time.deltaTime;
		}
		else
		{
			//movementDir = new Vector3(movementDir.x, 0.0f, movementDir.z);
			if (transform.up.y < 0.0f)
				transform.up = new Vector3(transform.up.x, -transform.up.y, transform.up.z);
			
			//verticalSpeed = 0.0f;
			
			if (Input.GetKey(KeyCode.Space) && IsGrounded())
			{
				if (debugging)
					Debug.Log("Jumpping = " + jumpSpeed);
				
				verticalSpeed = jumpSpeed;
			}
		}
		
		//apply gravity
		movementDir.y += verticalSpeed;
		
		//calculate displacement
		movementDir *= Time.deltaTime;
		
		if (!IsGrounded())
		{
			transform.forward = Vector3.Slerp(transform.forward, movementDir.normalized, 0.25f * Time.deltaTime);
		}
		
		Vector3 movement = movementDir;
		
		c_collisionFlags = controller.Move(movement);	
		
		//CheckUpPos();
		
		//draw all axis of this object
		if (debugging)
			Debug.DrawRay(transform.position, transform.up * 5, Color.red);
		if (debugging)
			Debug.DrawRay(transform.position, transform.forward * 5, Color.blue);
		if (debugging)
			Debug.DrawRay(transform.position, transform.right * 5, Color.green);
	}
	
	//*** custome functions *******************************************************************************************
	//check if player is on the groung
	bool IsGrounded () 
	{
		return (c_collisionFlags & CollisionFlags.CollidedBelow) != 0;
	}
	
	//apply external velocity to a player gets magnitud and normalized direction
	//public IEnumerator ApplyForceSpeed(float In_speed, Vector3 In_vect)
	public void ApplyForceSpeed(float In_speed, Vector3 In_vect)
	{
		//yield return new WaitForSeconds(0.15f);
		
		//if (debugging)
			Debug.Log("Applying force of " + In_speed + " with direction " + In_vect);
		
		applyAirFriction = true;
		externalSpeed 	= In_speed;
		transform.forward = In_vect.normalized;
	}
	
	//make sure player does not falls on its side
	void CheckUpPos()
	{
		if (Vector3.Dot(transform.up.normalized, Vector3.up.normalized) > Mathf.Cos(Mathf.Deg2Rad * 30.0f))
		{
			transform.up = Vector3.up;
		}
	}
}
