using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class motionBlurDandN : PostEffectsBase
{

    public Shader motionBlurShader;
    private Material motionBlurMaterial;
    public Material material
    {
        get
        {

            motionBlurMaterial = CheckShaderAndCreateMaterial(motionBlurShader, motionBlurMaterial);
            return motionBlurMaterial;

        }
    }

    private Camera myCamera;
    public Camera camera
    {
        get
        {

            if(myCamera == null)
            {
                myCamera = GetComponent<Camera>();
            }
            return myCamera;
        }
    }

    [Range(0.0f, 1.0f)]
    public float blurSize = 0.5f;

    private Matrix4x4 previousViewProjectionMatrix;

    //private RenderTexture accumulationTexture;

    private void OnEnable()
    {

        camera.depthTextureMode |= DepthTextureMode.Depth;
        previousViewProjectionMatrix = camera.projectionMatrix * camera.worldToCameraMatrix;

    }
    /*
    private void OnDisable()
    {
        DestroyImmediate(accumulationTexture);
    }
    */
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        
        if(material != null)
        {

            material.SetFloat("_blurSize", blurSize);
            material.SetMatrix("_PreviousViewProjectionMatrix", previousViewProjectionMatrix);
            Matrix4x4 currentViewProjectionMatrix = camera.projectionMatrix * camera.worldToCameraMatrix;
            Matrix4x4 currentViewProjectionInverseMatrix = currentViewProjectionMatrix.inverse;
            material.SetMatrix("_CurrentViewProjectionInverseMatrix", currentViewProjectionInverseMatrix);
            previousViewProjectionMatrix = currentViewProjectionMatrix;

            /*
            if (accumulationTexture == null || accumulationTexture.width != source.width || accumulationTexture.height != source.height)
            {

                DestroyImmediate(accumulationTexture);
                accumulationTexture = new RenderTexture(source.width, source.height, 0);
                accumulationTexture.hideFlags = HideFlags.HideAndDontSave;
                Graphics.Blit(source, accumulationTexture);

            }

            accumulationTexture.MarkRestoreExpected();
            material.SetTexture("_PreviousMainTex", accumulationTexture);
            */

            Graphics.Blit(source, destination, material);

        }
        else
        {
            Graphics.Blit(source, destination); 
        }

    }

}
