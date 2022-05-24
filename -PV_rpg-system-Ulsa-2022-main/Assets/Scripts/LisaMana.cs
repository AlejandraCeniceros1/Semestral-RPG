using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class LisaMana : Hero
{
    public Slider manaActual;

     [SerializeField]
    protected float _manaLisa; 

    void Start()
    {
        manaActual.GetComponent<Slider>().value = _manaLisa;
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.X))
		{
		_manaLisa -= 8.0f;
        }

    manaActual.GetComponent<Slider>().value = _manaLisa;

    if (_healthHero <= 0)
        {
            
            _manaLisa = 0f;
        }

    }
}
