#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt


# In[4]:


df = pd.read_csv(r"C:\Users\ASUS\OneDrive\Documents\Studies\Data analyst\Python\Python tutorial\Pandas\world_population.csv")
df


# In[3]:


pd.set_option('display.float_format',lambda x: '%.2f' % x)


# In[6]:


df.info()


# In[7]:


df.describe()


# In[8]:


df.isnull().sum()


# In[9]:


df.nunique()


# In[15]:


df.sort_values(by="World Population Percentage", ascending =False).head(10)


# In[19]:


df.corr(numeric_only=True)


# In[23]:


sns.heatmap(df.corr(numeric_only =True), annot = True)

plt.rcParams['figure.figsize'] = (20,7)
plt.show()


# In[24]:


df


# In[29]:


df.groupby('Continent').mean(numeric_only =True).sort_values(by="2022 Population", ascending=False)


# In[28]:


df[df['Continent'].str.contains('Oceania')]


# In[50]:


df2 = df.groupby('Continent')[['1970 Population', '1980 Population', '1990 Population', '2000 Population',
       '2010 Population', '2015 Population', '2020 Population',
       '2022 Population']].mean(numeric_only =True).sort_values(by="2022 Population", ascending=False)
df2

#df2 = df.groupby('Continent')[df.columns[5:13]].mean(numeric_only =True).sort_values(by="2022 Population", ascending=False)
#df2


# In[38]:


df.columns


# In[51]:


df3 = df2.transpose()
df3


# In[52]:


df3.plot()


# In[54]:


df.boxplot(figsize = (20,10))


# In[59]:


df.select_dtypes(include = 'float')


# In[ ]:




