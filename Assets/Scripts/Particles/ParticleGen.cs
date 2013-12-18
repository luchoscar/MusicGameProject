using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class ParticleGen : MonoBehaviour 
{
	public bool debugging;
	
	#region Variables 
	private float timer = 0.0f;
	private bool startEmitting = false;
	private float delayEmitTime = 0.0f;
	private const float MAX_DELAY = 0.5f;
	
	public float partSize = 0.5f;
	public Shader mainShader;
	public float velocity;
	public Vector3 direction;
	public float life;
	public float spawnTime = 0.5f;
	public Texture2D partText;
	public Transform partPrefab;
	
	#endregion
	
	void Start()
	{
		delayEmitTime = Random.Range(0.0f, MAX_DELAY);	
	}
	
	void Update()
	{
		if (startEmitting)
		{
			timer += Time.deltaTime;
			
			if (timer >= spawnTime)
			{
				timer = 0.0f;
				direction = Random.insideUnitSphere;
				direction = new Vector3(Random.Range(-0.2f, 0.2f), Mathf.Max(0.5f, Mathf.Abs(direction.y)), Random.Range(-0.2f, 0.2f));
				//direction = Vector3.up;
				CreateParticle();
			}
		}
		else
		{
			timer += Time.deltaTime;
			
			if (timer >= delayEmitTime)
			{
				timer = 0.0f;
				startEmitting = !startEmitting;
			}
		}
	}
	
	//Transform CreateParticle()
	void CreateParticle()
	{
		Vector3 partPos = transform.position + (new Vector3(0.0f, Random.Range(0.5f, transform.localScale.y), 0.0f));
		
		Transform part = Instantiate(partPrefab, partPos, Quaternion.identity) as Transform;
		
		if (debugging)
			Debug.Log(this.name + " " + transform.parent.parent.position);
		
		if (transform.parent.parent.tag != "PlayerController")
			part.parent = transform;
//		part.renderer.enabled = false;
		part.GetComponent<MyParticle>().SetUp(velocity, direction.normalized, mainShader, partText, life, partSize);
		
		
//		return part;
	}
}

