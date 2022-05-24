using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ButtonAnimationLoop : MonoBehaviour
{
    public Sprite[] altSprite;
    int currentSprite;

    void Start()
    {
        StartCoroutine(SwitchSprite());
    }

    IEnumerator SwitchSprite(){
        while(enabled)
        {          
            yield return new WaitForSeconds(0.2f);
            GetComponent<Image>().sprite = altSprite[currentSprite];
            GetComponent<Image>().SetNativeSize();
            currentSprite++;   
            if(currentSprite >= altSprite.Length)
            {
                currentSprite = 0;   
            }     
        }
    }
}
