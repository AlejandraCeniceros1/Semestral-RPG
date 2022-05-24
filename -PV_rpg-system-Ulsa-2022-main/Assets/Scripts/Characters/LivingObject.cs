using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class LivingObject : MonoBehaviour, IDamagable
{
    [SerializeField]
    protected int health;
    [SerializeField]
    protected int maxHealth;
    
    public int GetHealth()
    {
        return health;
    }

    public bool ImDead()
    {
        return health == 0;
    }
    /*public int GetHealth => health;
    public bool ImDead => health == 0;*/

    public void ReciveDamage(int damage) => health = health - damage > 0 ? health - damage : 0;

    public void AddHealt(int health) => this.health += this.health + health <= maxHealth ? this.health + health : 0;
    
}