using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

[RequireComponent(typeof(InputsController))]
public class Hero : Character, IHostile
{
    [SerializeField]
    protected int damage;
    [SerializeField]
    protected JobsOptions jobsOptions;
    [SerializeField]
    CharacterJob currentJob;
    [SerializeField]
    float leaderMinDistance;

    bool IsFollowing = false;

    [SerializeField]
    Vector2 minMaxAngle;
    protected float movementValue;
    protected InputsController inputsController;
    [SerializeField]
    private float _rotSpeed = 20f;

    protected bool isAttacking;
    private float NotAttack = 0.5f;

    [SerializeField]
    protected float _healthHero;

    new void Awake()
    {
        base.Awake();
        inputsController = GetComponent<InputsController>();
    }

    IEnumerator Start()
    {
        agent.speed = moveSpeed;
        agent.stoppingDistance = leaderMinDistance;
        while(true)
        {
            if(Gamemanager.Instance.CurrentGameMode)
            {
                agent.enabled = !ImLeader;
                break;
            }
            yield return null;
        }
    }

    protected override void Movement()
    {
        Hero leader = Gamemanager.Instance.CurrentGameMode.GetPartyLeader.GetComponent<Hero>();
        NotAttack -= Time.deltaTime;
        if(ImLeader)
        {
            //IsFollowing = false;
            base.Movement();
            transform.Translate(inputsController.Axis.normalized.magnitude * Vector3.forward * moveSpeed * Time.deltaTime);
            FacingDirection();
            movementValue = leader.IsMoving ? 1 : 0f;

            if(NotAttack <= 0.0f)
            {
                isAttacking = false;
                NotAttack = 0.5f;
            }

           // Gamemanager.Instance.CurrentGameMode.GetGameUI.Health = health * 100f / maxHealth;
        }
        else
        {
            if(agent.enabled)
            {
                agent.destination = leader.transform.position;
                movementValue = agent.velocity != Vector3.zero ? 1 : 0f;
            }
        }
    }

    protected void LateUpdate()
    {
        anim.SetFloat("moveSpeedMultiplier", Mathf.Clamp01(Mathf.Abs(inputsController.Axis.magnitude)));
    }

    public void Attack()
    {

    }

    public int GetDamage()
    {
        return damage;
    }

/// <summary>
/// Checks if you are the leader of the party.
/// </summary>
/// <returns>Returns a true/false depending of the comparing with leader transform.</returns>
    public bool ImLeader => Gamemanager.Instance.CurrentGameMode.CompareToLeader(transform);

    protected void FacingDirection()
    {
        if(IsMoving)
        {
            transform.rotation = Quaternion.Lerp(transform.rotation, RotationDirection, Time.deltaTime * _rotSpeed);
        }
    }

    Quaternion RotationDirection => Quaternion.LookRotation(inputsController.Axis);

    public bool IsMoving => inputsController.Axis != Vector3.zero;

    public CharacterJob CurrentJob{get => currentJob; set => currentJob = value;}
    public JobsOptions GetJobsOptions => jobsOptions;
    public NavMeshAgent GetAgent => agent;

    public InputsController GetInputsController => inputsController;
    public float GetMovementValue => Mathf.Abs(movementValue);
    public bool IsAttack{set => isAttacking = value;}

}
