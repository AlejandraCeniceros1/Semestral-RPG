using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class BartMana : MonoBehaviour
{
    public Slider manaActual;

    
    [SerializeField]
    protected float _manaBart;

    void Start()
    {
        manaActual.GetComponent<Slider>().value = _manaBart;

    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.X))
		{
		_manaBart -= 8.0f;
        }

    manaActual.GetComponent<Slider>().value = _manaBart;

    }
}
