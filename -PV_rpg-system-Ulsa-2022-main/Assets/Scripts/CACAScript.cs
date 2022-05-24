using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;


public class CACAScript : MonoBehaviour
{
    public Slider vidaVisual;

    
    [SerializeField]
    protected float _healthCaca;  
    
    void Start()
    {
        vidaVisual.GetComponent<Slider>().value = _healthCaca;
        


    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.X))
		{
		_healthCaca -= 15.0f;

        }
    }

    
}
