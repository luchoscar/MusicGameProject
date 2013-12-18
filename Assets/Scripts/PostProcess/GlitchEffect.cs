using UnityEngine;

[ExecuteInEditMode]
[AddComponentMenu("Image Effects/GlitchEffect")]
public class GlitchEffect : MonoBehaviour {
	
	public Texture2D displacementMap;
	float glitchup, glitchdown, flicker,
			glitchupTime = 0.05f, glitchdownTime = 0.05f, flickerTime = 0.5f;
	
	private Material curMaterial;
	public Shader curShader;
	
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
	
	// Called by camera to apply image effect
	void OnRenderImage (RenderTexture source, RenderTexture destination) 
	{
		
		material.SetTexture("_DispTex", displacementMap);
		
		glitchup += Time.deltaTime;
		glitchdown += Time.deltaTime;
		flicker += Time.deltaTime;
		
		if(flicker > flickerTime)
		{
			material.SetFloat("filterRadius", Random.Range(-3f, 3f));
			flicker = 0;
			flickerTime = Random.value;
		}
		
		if(glitchup > glitchupTime)
		{
			if(Random.value < 0.1f)
				material.SetFloat("flip_up", Random.Range(0, 1f));
			else
				material.SetFloat("flip_up", 0);
			
			glitchup = 0;
			glitchupTime = Random.value / 10f;
		}
		
		if(glitchdown > glitchdownTime)
		{	
			if(Random.value < 0.1f)
				material.SetFloat("flip_down", Random.Range(0, 1f));
			else
				material.SetFloat("flip_down", 1);
			
			glitchdown = 0;
			glitchdownTime = Random.value / 10f;
		}
		
		if(Random.value < 0.05)
			material.SetFloat("displace", Random.value);
		else
			material.SetFloat("displace", 0);
		
		Graphics.Blit (source, destination, material);
	}
}