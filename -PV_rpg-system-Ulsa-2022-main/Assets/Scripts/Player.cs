using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement; 

public class Player : MonoBehaviour
{

	public int maxHealth = 100;
	public int currentHealth;
    //public int ZeroHealth = currentHealth ;

	public HealthBar healthBar;

    // Start is called before the first frame update
    void Start()
    {
		currentHealth = maxHealth;
		healthBar.SetMaxHealth(maxHealth);
    }

    // Update is called once per frame
    void Update()
    {
		if (Input.GetKeyDown(KeyCode.X))
		{
			TakeDamage(10);
		}
        if (Input.GetKeyDown(KeyCode.P))
		{
			SceneManager.LoadScene(0); 
		}
/*
        if (ZeroHealth = 0)
        {
            SceneManager.LoadScene(0);
        }
*/
    }

	void TakeDamage(int damage)
	{
		currentHealth -= damage;

		healthBar.SetHealth(currentHealth);
	}
}
