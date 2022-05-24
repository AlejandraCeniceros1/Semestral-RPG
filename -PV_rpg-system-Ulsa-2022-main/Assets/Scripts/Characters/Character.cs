using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

[RequireComponent(typeof(Animator))]
[RequireComponent(typeof(CapsuleCollider))]
[RequireComponent(typeof(NavMeshAgent))]
public class Character : LivingObject
{
    [SerializeField]
    protected Lore lore;
    [SerializeField, Range(0.1f, 15f)]
    protected float moveSpeed = 5f;
    protected Animator anim;
    protected Vector3 lastPostion;
    protected NavMeshAgent agent;

    protected void Awake()
    {
        anim = GetComponent<Animator>();
        agent = GetComponent<NavMeshAgent>();
    }

    protected void Update()
    {
        lastPostion = transform.position;
        Movement();
    }
    protected virtual void Movement ()
    {
        
    }

    public bool IsTranslating => transform.position - lastPostion != Vector3.zero;
}
