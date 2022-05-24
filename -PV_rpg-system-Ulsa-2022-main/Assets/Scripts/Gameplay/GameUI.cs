using System.Collections;
using System.Collections.Generic;
using UnityEditor.UIElements;
using UnityEngine;
using UnityEngine.UIElements;

public class GameUI : MonoBehaviour
{
    private UIDocument _uiDoc;
    private ProgressBar _healthbar;
    private ProgressBar _manabar;

    private void Awake()
    {
        _uiDoc = GetComponent<UIDocument>();
    }

    private void Start()
    {
        _healthbar = _uiDoc.rootVisualElement.Q<ProgressBar>("health");
        _manabar = _uiDoc.rootVisualElement.Q<ProgressBar>("mana");
    }

    public float Health{get => _healthbar.value; set => _healthbar.value = value;}
    public float Mana{get => _manabar.value; set => _manabar.value = value;}
    
    
}
