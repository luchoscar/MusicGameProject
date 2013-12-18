/****************************************************************
 * By Luis Saenz												*
 * Script setup different walls on the level at run time		*
 * Walls are placed at random on a grid sequence				*
 * Track number of collectable items in level					*
 * 																*
 ****************************************************************/


using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class LevelBuilder : MonoBehaviour 
{
	private int level_idx = -1;
	private bool playing = true;										//flag indicating level has not ended
	
	public bool createLevelOnAwake = false;
	public bool debugging;
	public bool createDummyWalls;										//flag to display spheres where walls are not created
	public Transform innerWalls;										//object to hold all inner walls in level
	public float x_size, z_size;										//max size of are to build (rectangle shape)
	public int x_sizeDiv, z_sizeDiv;									//max number of division on x & z axis
	public List<Transform> laberintWallPrefab = new List<Transform>();	//list to hold wall prefabs
	public List<Vector3> intersectPoints = new List<Vector3>();			//list to hold grid position were to place walls
	public float wallPer;												//scale percent for walls xz
	public static int collectTotal = 0;
	
	private static int X_divInc = 1;
	private static int Z_divInc = 1;
	
	// Use this for initialization
	void Awake () 
	{
		if (innerWalls == null)
			innerWalls = transform.GetChild(0).transform;
		
		if (createLevelOnAwake)
		{
			CollectableScript.dynamicLevel = true;
			SetWorldWalls();
			SetDivisionPoints();
			
			LevelBuilder.collectTotal = GameObject.FindGameObjectsWithTag("MusicNote").Length;
		}
	}
	
	void Start()
	{
		GameObject.FindGameObjectWithTag("ground").renderer.material.SetFloat("_minDist", 25.0f);
	}
	
	void LateUpdate()
	{
		if (CheckForWin())
		{
			Debug.Log("No more collectables");
		}
		else
		{
			Debug.Log("Collectanle remaining " + LevelBuilder.collectTotal);
		}
	}
	
	//sets divisions on the level area
	void SetDivisionPoints()
	{
		//do not create anything if there is only 1 segment on x or z
		if (x_sizeDiv <= 1 || z_sizeDiv <= 1)
		{
			Debug.Log("need more than one division to create walls on X AND Z --> x_sizeDiv = " + x_sizeDiv + " & z_sizeDiv = " + z_sizeDiv);
			return;
		}
		
		List<float> x_pos = new List<float>();
		SetPositions(x_pos, x_size, x_sizeDiv);
		
		if (debugging)
			DebugPositionList(x_pos);
		
		List<float> z_pos = new List<float>();
		SetPositions(z_pos, z_size, z_sizeDiv);
		
		
		if (debugging)
			DebugPositionList(z_pos);
		
		CreateLabWalls(x_pos, z_pos, x_size / x_sizeDiv, z_size / z_sizeDiv);
	}
	
	//store float position in an external list
	//takes in external list, external float of max size and int of number of divisions
	void SetPositions(List<float> In_List, float In_size, int In_div)
	{
		//calculate widht values
		float delta = In_size / In_div;
		
		//set new min & max boundaries
		float x_minB = transform.position.x - In_size * 0.5f;
		float x_maxB = transform.position.x + In_size * 0.5f;
		
		while(x_minB <= x_maxB)
		{
			In_List.Add(x_minB);
			x_minB += delta;
		}
	}
	
	//debug function for positions
	void DebugPositionList(List<float> In_list)
	{
		string strPos = "";
		for(int i = 0; i < In_list.Count; i++)
		{
			strPos += (In_list[i] + " ");
		}
		
		Debug.Log(strPos);
	}
	
	//creates prefab wall with random y-rotation & x-scale = x_delta/4 & z-scale = z_delta/4
	void CreateLabWalls(List<float> In_X, List<float> In_Z, float In_x_delta, float In_z_delta)
	{
		for(int x = 1; x < In_X.Count - 1; x++)
		{
			for(int z = 1; z < In_Z.Count - 1; z++)
			{
				int idx = Random.Range(0, laberintWallPrefab.Count + 1);	//max random numb = size of array in order not to create an object on that grid point
				if (idx < laberintWallPrefab.Count - 1)
				{
					Transform labWall = Instantiate (laberintWallPrefab[idx], new Vector3(In_X[x], transform.position.y, In_Z[z]), Quaternion.identity) as Transform;

					if (labWall.tag == "MusicNoteHolder")
					{
						labWall.position = new Vector3(labWall.position.x, Random.Range(labWall.position.y, labWall.position.y + 5.0f), labWall.position.z);
					}
					else if (wallPer > 0.0f)
					{
						labWall.localScale = new Vector3(labWall.localScale.x * wallPer, labWall.localScale.y, labWall.localScale.z * wallPer);
					}
					
					labWall.parent = innerWalls;
				}
				else 
				{
					Transform labWall = Instantiate (laberintWallPrefab[laberintWallPrefab.Count - 1], new Vector3(In_X[x], transform.position.y, In_Z[z]), Quaternion.identity) as Transform;
					labWall.localScale = new Vector3(labWall.localScale.x * wallPer, labWall.localScale.y * wallPer, labWall.localScale.z * wallPer);
					labWall.parent = innerWalls;
				}
				
				if (debugging)
					Debug.Log("(" + In_X[x] + ", " + In_Z[z] + ")");
			}
		}
	}
	
	bool CheckForWin()
	{
		if (LevelBuilder.collectTotal == 0)
		{
			if (playing)
			{
				StartCoroutine(LoadNextLevel());
				playing = false;
			}
			return true;
		}
		
		return false;
	}
	
	//function to set world scale 
	void SetWorldWalls()
	{
		//set ground scale
		Transform ground = GameObject.FindGameObjectWithTag("ground").transform;
		float scalRatio = ground.localScale.x * 0.5f * 0.01f; 
		ground.localScale = new Vector3(scalRatio * x_size, ground.localScale.y, z_size * scalRatio);
		
		//set wall scale
		GameObject[] walls = GameObject.FindGameObjectsWithTag("worldWall");
		Transform tempWall = GameObject.FindGameObjectWithTag("worldWall").transform;
		scalRatio = tempWall.localScale.z * 0.5f * 0.01f;
		int x = 1;
		int z = 1;
		
		foreach(GameObject wall in walls)
		{
			if (wall.transform.position.x > 0.01f || wall.transform.position.x < -0.01f)
			{
				wall.transform.position = new Vector3(x_size * 0.5f * x, wall.transform.position.y, wall.transform.position.z);
				
				x *= -1;
			}
			else
			{
				wall.transform.position = new Vector3(wall.transform.position.x, wall.transform.position.y, z_size * 0.5f * z);
				z *= -1;
			}
			
			wall.transform.localScale = new Vector3(wall.transform.localScale.x, wall.transform.localScale.y, z_size * scalRatio);
		}
		
		//set player's light range
		Light playerLight = GameObject.FindGameObjectWithTag("playerLight").transform.light;
		playerLight.range = Mathf.Sqrt(x_size * x_size + z_size * z_size) * 0.25f;
	}
	
	//load next procedural level generated
	public IEnumerator LoadNextLevel()
	{
		if (debugging)
			Debug.Log("Before sleep " + Time.time);
		
		yield return new WaitForSeconds(5);
		
		if (debugging)
			Debug.Log("After sleep " + Time.time);
		
		Application.LoadLevel(level_idx);
	}
	
	public void OnLevelWasLoaded(int level)
	{
		level_idx = level;
		
		CollectableScript.dynamicLevel = true;
		
		LevelBuilder.X_divInc += 2;
		LevelBuilder.Z_divInc += 2;
		x_sizeDiv += LevelBuilder.X_divInc;
		z_sizeDiv += LevelBuilder.Z_divInc;
		Debug.Log("tst");
		
		SetWorldWalls();
		SetDivisionPoints();
		
		LevelBuilder.collectTotal = GameObject.FindGameObjectsWithTag("MusicNote").Length;
		
		if (x_sizeDiv > 20) x_sizeDiv = 20;
		if (z_sizeDiv > 20) z_sizeDiv = 20;
	
	}
}
