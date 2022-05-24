using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;
using UnityEditor.Animations;

public class GameMode : MonoBehaviour
{
    [SerializeField]
    private List<Transform> party;
    private Queue<Transform> partyQueue;
    private CinemachineVirtualCamera pCamera;
    private GameUI _gameUI;

    IEnumerator Start()
    {
        pCamera = GameObject.FindGameObjectWithTag("Pcamera").GetComponent<CinemachineVirtualCamera>();
        _gameUI = GameObject.FindWithTag("UI").GetComponent<GameUI>();
        while(true)
        {
            if(Gamemanager.Instance)
            {
                partyQueue = new Queue<Transform>(party);
                //partyQueue.Peek();
                Gamemanager.Instance.CurrentGameMode = this;
                break;
            }
            yield return null;
        }
    }

    void Update()
    {
        
    }

    public GameUI GetGameUI => _gameUI;

    public Transform GetPartyLeader => partyQueue.Peek();

    public bool CompareToLeader(Transform leader) => GetPartyLeader.Equals(leader);

    public void ChangeLeader(Transform hero)
    {
        if(CompareToLeader(hero))
        {
            partyQueue.Enqueue(partyQueue.Dequeue());
            List<Transform> partyList = new List<Transform>(partyQueue);
            partyList.ForEach((e) => {
                Hero hero = e.GetComponent<Hero>();
                if(CompareToLeader(e))
                {
                    hero.GetAgent.enabled = false;
                    hero.GetInputsController.enabled = true;
                    pCamera.Follow = e;
                    pCamera.LookAt = e;
                }
                else
                {
                    hero.GetAgent.enabled = true;
                    hero.GetInputsController.enabled = false;
                }
            });
        }
    }
}
