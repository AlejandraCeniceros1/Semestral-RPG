using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Maggie : Hero

{       
    
     public Slider vidaVisual;

    protected override void Movement()
    {

        //if(gamemanager,.insta.gamemode.GetLeader.gameObject == gameObject)
        base.Movement();
        anim.SetFloat("Move", Mathf.Abs(movementValue));

        vidaVisual.GetComponent<Slider>().value = _healthHero;

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
