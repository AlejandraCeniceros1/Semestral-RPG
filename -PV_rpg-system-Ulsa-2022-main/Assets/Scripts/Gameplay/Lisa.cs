using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Lisa : Hero
{

    protected override void Movement()
    {
        base.Movement();

        anim.SetFloat("move", movementValue);

        if(ImLeader)
        {
            anim.SetBool("Attack", isAttacking);
        }

        if (_healthHero <= 50)
        {
            anim.SetBool("Damage", true);
            
        }

        if (_healthHero <= 10)
        {
            anim.SetBool("Damage", true);
            
        }

         if (_healthHero <= 0)
        {
            anim.SetBool("Die", true);
            this.GetComponent<InputsController>().enabled = false;
            agent.enabled = false;
            Gamemanager.Instance.CurrentGameMode.ChangeLeader(transform);
        }
        
    }

     void OnTriggerEnter(Collider other)
    {
        if(other.CompareTag("Ball"))
        {
            _healthHero -= 15.0f;
        }
    }

}