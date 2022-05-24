using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Gamemanager : MonoBehaviour
{
    
    public static Gamemanager Instance;
    [SerializeField]
    GameMode gameMode;

    void Awake()
    {
        if(!Instance)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }
    }

    public GameMode CurrentGameMode{ get => gameMode; set => gameMode = value;}
}
