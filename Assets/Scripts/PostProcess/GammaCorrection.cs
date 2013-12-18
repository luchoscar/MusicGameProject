using UnityEngine;
using System.Collections;

//[ExecuteInEditMode]
public class GammaCorrection : MonoBehaviour 
{
	#region Variables 
	public bool debugging;
	
	public Shader curShader;
	public float brightnessAmount = 1.0f;
	public float saturationAmount = 1.0f;
	public float contrastAmount = 1.0f;
	private Material curMaterial;
	
	#endregion
	
	#region Properties
	
	Material material
	{
		get
		{
			if (curMaterial == null)
			{
				curMaterial = new Material(curShader);
				curMaterial.hideFlags = HideFlags.HideAndDontSave;
			}
			
			return curMaterial;
		}
	}
	
	#endregion
	
	// Use this for initialization
	void Start () 
	{
		if (debugging)
			Debug.Log("Gama start");
		
		if (!SystemInfo.supportsImageEffects)
		{
			enabled = false;
			return;
		}
		
		if (!curShader && !curShader.isSupported)
		{
			enabled = false;
		}	
	}
	
	// Update is called once per frame
	void Update () 
	{
		if (debugging)
			Debug.Log("Gama Update");
		//brightnessAmount += 0.5f * Time.deltaTime;
		
		//if (brightnessAmount > 2.0f) brightnessAmount = 0.0f;
		
		brightnessAmount = Mathf.Clamp(brightnessAmount, 0.0f, 2.0f);
	    saturationAmount = Mathf.Clamp(saturationAmount, 0.0f, 2.0f);
	    contrastAmount = Mathf.Clamp(contrastAmount, 0.0f, 3.0f);
	}
	
	void OnDisable()
	{
		if (curMaterial)
		{
			DestroyImmediate(curMaterial);
		}
	}
	
	void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
	{
		if (curShader != null)
		{
			if (debugging)
				Debug.Log("Passing values to shader");
			
			material.SetFloat("_BrightnessAmount", brightnessAmount);
			material.SetFloat("_satAmount", saturationAmount);
			material.SetFloat("_conAmount", contrastAmount);
			Graphics.Blit(sourceTexture, destTexture, material);
		}
		else
		{	
			Debug.Log("Nothing");
			Graphics.Blit(sourceTexture, destTexture);
		}
	}
}
