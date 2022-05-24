using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;


public class Lisa : Hero
{
    public Slider vidaVisual;
      public Slider manaActual;

    [SerializeField]
    protected float _manaLisa; 

    protected override void Movement()
    {
        base.Movement();

        anim.SetFloat("move", movementValue);
        
        vidaVisual.GetComponent<Slider>().value = _healthHero;
        manaActual.GetComponent<Slider>().value = _manaLisa;
      
        if(ImLeader)
        {
            anim.SetBool("Attack", isAttacking);
            if (Input.GetKeyDown(KeyCode.X))
            {
            _manaLisa -= 8.0f;
            }
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