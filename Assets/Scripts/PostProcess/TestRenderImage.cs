using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class TestRenderImage : MonoBehaviour
{
	#region Variables
	public Shader curShader;
	public float grayScaleAmount = 1.0f;
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
	void Start() 
	{
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
	void Update() 
	{
		grayScaleAmount = Mathf.Clamp(grayScaleAmount, 0.0f, 1.0f);
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
			material.SetFloat("_LuminosityAmount", grayScaleAmount);
			Graphics.Blit(sourceTexture, destTexture, material);
		}
		else
		{
			Graphics.Blit(sourceTexture, destTexture);
		}
	}
}
