using UnityEngine;
using System.Collections;

public class IntroScene : MonoBehaviour 
{
	Transform playerObj;
	//int dir = 1;
	float angleAnim;
	
	public float xMax = 4.27f;//, xMin;
	public float animSpeed = 0.01f;
	
	// Use this for initialization
	void Start () 
	{
		if (playerObj == null)
			playerObj = GameObject.FindGameObjectWithTag("Player").transform;
	}
	
	// Update is called once per frame
	void Update () 
	{
		angleAnim += (Time.deltaTime / animSpeed);
		playerObj.Rotate(Vector3.up, -animSpeed);
		
		playerObj.position = new Vector3(Mathf.Sin(angleAnim) * xMax, 0.0f, 0.0f);
		
		if (angleAnim >= 2.0f * Mathf.PI)
			angleAnim -= 2.0f * Mathf.PI;
	}
	
	void OnGUI() 
	{
		if (GUI.Button(new Rect(10, 10, 150, 50), "Play Game"))
		{
			print("You clicked the button!");
			Application.LoadLevel(1);
		}
    }

	void OnLevelWasLoaded(int level)
	{
		GameObject [] randomNotes = GameObject.FindGameObjectsWithTag ("randomNote");
		for (int i = randomNotes.Length - 1; i >= 0; i--) 
		{
				Destroy (randomNotes [i]);
		}
	}
}
