using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class CambioScena : MonoBehaviour
{
    
    private void OnTriggerEnter( Collider other) {

        if(other.tag == "Player")
        {
            SceneManager.LoadScene("battleScene");
        }
    
    }
}
