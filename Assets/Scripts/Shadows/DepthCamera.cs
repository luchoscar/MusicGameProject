using UnityEngine;
using System.Collections;

public class DepthCamera : MonoBehaviour 
{
	public Matrix4x4 viewMatrix;
	
	// Use this for initialization
	void Start () 
	{
		camera.depthTextureMode = DepthTextureMode.Depth;
		viewMatrix = camera.worldToCameraMatrix;
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
