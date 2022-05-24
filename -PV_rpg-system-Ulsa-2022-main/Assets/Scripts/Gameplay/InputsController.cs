using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;


public class InputsController : MonoBehaviour
{
    GameInputs gameInputs;
    private Animator animator;

    Hero hero;

    void Awake()
    {
        gameInputs = new GameInputs();
        
        
    }

    void OnEnable()
    {
        gameInputs.Enable();
        gameInputs.Gameplay.ChangeJob.performed += OnHeroJobChanged;
        gameInputs.Gameplay.ChangeLeader.performed += OnLeaderChanged;
    }

    void OnDisable()
    {
        gameInputs.Disable();
        gameInputs.Gameplay.ChangeJob.performed -= OnHeroJobChanged;
        gameInputs.Gameplay.ChangeLeader.performed -= OnLeaderChanged;
    }

    private void OnHeroJobChanged(InputAction.CallbackContext ctx) => ChangeJob(hero.GetJobsOptions);
    private void OnLeaderChanged(InputAction.CallbackContext ctx) => PassLeaderToNextone();

    void Start()
    {
        hero = GetComponent<Hero>();
        ChangeJob(hero.GetJobsOptions);
        gameInputs.Gameplay.Attack.performed +=_=> Attacking();
       
    }

    void ChangeJob(JobsOptions job)
    {

        if(hero.CurrentJob)
        {
            Destroy(hero.CurrentJob);
        }
        switch(job)
        {
            case JobsOptions.MAGE:
            hero.CurrentJob = gameObject.AddComponent<Mage>();
            break;
            case JobsOptions.ARCHER:
            hero.CurrentJob = gameObject.AddComponent<Archer>();
            break;
            case JobsOptions.WARRIOR:
            hero.CurrentJob = gameObject.AddComponent<Warrior>();
            break;
        }
    }
    

    

    void PassLeaderToNextone()
    {
        Gamemanager.Instance.CurrentGameMode.ChangeLeader(transform);
    }

    void Attacking()
    {
        hero.IsAttack = true;
    }

    public GameInputs GetGameinputs => gameInputs;

    public Vector3 Axis => new Vector3(Direction.x, 0f, Direction.y);

    public Vector2 Direction => gameInputs.Gameplay.Direction.ReadValue<Vector2>();
}
