using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bart : Hero
{
    protected override void Movement()
    {
        base.Movement();
        anim.SetFloat("move", movementValue);

        if(ImLeader)
        {
            anim.SetBool("Attack", isAttacking);
        }
        
    }

}
