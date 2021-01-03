---
layout: post
title: "SpringIOC后处理器"
tags: Spring 
---

### BeanPostProcessor

BeanPostProcessor有几个子接口如果一个BeanPostProcessor的实现类是实现这几个子接口的那么会被放入BeanPostProcessorCache中在Bean的初始化过程中这几个子接口的实现类会单独做一些特殊的处理

对于BeanPostProcessor的实现代码基本都在createBean方法中。（类的销毁目前先不要去关心）

```java
BeanPostProcessorCache getBeanPostProcessorCache() {
   BeanPostProcessorCache bpCache = this.beanPostProcessorCache;
   if (bpCache == null) {
      bpCache = new BeanPostProcessorCache();
      for (BeanPostProcessor bp : this.beanPostProcessors) {
         if (bp instanceof InstantiationAwareBeanPostProcessor) {
            bpCache.instantiationAware.add((InstantiationAwareBeanPostProcessor) bp);
            if (bp instanceof SmartInstantiationAwareBeanPostProcessor) {
               bpCache.smartInstantiationAware.add((SmartInstantiationAwareBeanPostProcessor) bp);
            }
         }
         if (bp instanceof DestructionAwareBeanPostProcessor) {
            bpCache.destructionAware.add((DestructionAwareBeanPostProcessor) bp);
         }
         if (bp instanceof MergedBeanDefinitionPostProcessor) {
            bpCache.mergedDefinition.add((MergedBeanDefinitionPostProcessor) bp);
         }
      }
      this.beanPostProcessorCache = bpCache;
   }
   return bpCache;
}
```

BeanPostProcessor

+ InstantiationAwareBeanPostProcessor   扩展Bean的创建过程
+ MergedBeanDefinitionPostProcessor     扩展Bean定义
+ DestructionAwareBeanPostProcessor    扩展Bean的销毁过程

//todo 定义

InstantiationAwareBeanPostProcessor

在createBean方法中创建Bean之前会先去掉用InstantiationAwareBeanPostProcessor，如果这个后处理器放回非空就会直接返回InstantiationAwareBeanPostProcessor创建的对象，不再继续创建流程

```java
// Give BeanPostProcessors a chance to return a proxy instead of the target bean instance.
Object bean = resolveBeforeInstantiation(beanName, mbdToUse);
if (bean != null) {
	return bean;
}
```

其内部调用了postProcessBeforeInstantiation和postProcessAfterInstantiation方法

在随后的Bean初始化过程中设置Bean的属性时populateBean方法中会调用剩下的3个方法postProcessAfterInstantiation、postProcessProperties、postProcessPropertyValues

```java
if (!mbd.isSynthetic() && hasInstantiationAwareBeanPostProcessors()) {
   for (InstantiationAwareBeanPostProcessor bp : getBeanPostProcessorCache().instantiationAware) {
      if (!bp.postProcessAfterInstantiation(bw.getWrappedInstance(), beanName)) {
         return;
      }
   }
}
//...
//省略
//...
   for (InstantiationAwareBeanPostProcessor bp : getBeanPostProcessorCache().instantiationAware) {
      PropertyValues pvsToUse = bp.postProcessProperties(pvs, bw.getWrappedInstance(), beanName);
      if (pvsToUse == null) {
         if (filteredPds == null) {
            filteredPds = filterPropertyDescriptorsForDependencyCheck(bw, mbd.allowCaching);
         }
         pvsToUse = bp.postProcessPropertyValues(pvs, filteredPds, bw.getWrappedInstance(), beanName);
         if (pvsToUse == null) {
            return;
         }
      }
      pvs = pvsToUse;
   }
```