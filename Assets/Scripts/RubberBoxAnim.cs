/************************************************************************************
 * By Luis Saenz,																	*
 * Script to control rubber box animation and setup									*
 * 																					*
 ************************************************************************************/

using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class RubberBoxAnim : MonoBehaviour 
{
	public bool debugging;
	public int animIdx = 0;									//index of animation use for debugging correct animation applied to correct collider
	
	public float pushMag;									//magnitud of velocity applied when collided with
	public float animationSpeed = 20.0f;					//speed of animation to be played
	public Animation animation = new Animation();			//animation component of object
	public List<string> animStates = new List<string>();	//array holding all animation states of this obejct
	public Transform[] animTriggers;						//list holding all triggers of this obejct
	
	// Use this for initialization
	void Awake () 
	{
		animation = transform.animation;
		
		//store animation states in array 
		foreach(AnimationState state in animation)
		{
			state.speed = animationSpeed;
			animStates.Add(state.name);
		}
		
		if (debugging)
		{
			for (int i = 0; i < animStates.Count; i++)
			{
				for (int c = 0; c < animTriggers.Length; c++)
				{
					string strState = animStates[i];
					
					if(strState == animTriggers[c].name)
					{
						animTriggers[c].GetComponent<RubberBoxTrigger>().animIdx = i;
					}
				}
			}
		}
	}
	
	// Update is called once per frame
	void Update () 
	{
		
	}
	
	//play animation --> gets int idx = list index to implement
	public void PlayAnimation(int idx)
	{
		if (debugging) Debug.Log(animStates[idx]);
		
		animation.CrossFade(animStates[idx]);
	}
}
