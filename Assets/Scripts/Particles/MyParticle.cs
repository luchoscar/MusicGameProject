using UnityEngine;
using System.Collections;

public class MyParticle : MonoBehaviour 
{
	public bool debugging;
	
	Vector3 partPosition;
	public Vector3 direction = new Vector3(0.0f, 1.0f, 0.0f);
	float life;
	float maxLife;
	
	Texture2D partText;
	float velocity = 0.5f;
	Material curMaterial;
	Shader curShader;
	float partSize;

	public Material material
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
	
	public void SetUp(float In_vel, Vector3 In_dir, Shader In_shader, Texture2D In_text, float In_life, float In_size)
	{
		if (debugging)
			Debug.Log("Setting part");
		
		velocity = In_vel;
		direction = In_dir;
		curShader = In_shader;
		partText = In_text;
		material.SetTexture("_SpriteTex", partText);
		renderer.material = material;
		maxLife = In_life;
		partSize = In_size;
	}
	
	void Update()
	{
		life += Time.deltaTime;
		
		if (life >= maxLife)
			Destroy(this.gameObject);
		
		transform.position += direction * velocity * Time.deltaTime;
	}
	
	void LateUpdate()
	{
		//material.SetVector("partPos", partPosition);
		//material.SetVector("partPos", transform.position);
		material.SetVector("partPos", Vector3.zero);
		
		if(debugging)
			Debug.Log("Part " + transform.position);
		
		material.SetFloat("_Size", partSize);
	}
}