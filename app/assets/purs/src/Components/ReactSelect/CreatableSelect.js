import React from 'react'
import CreatableSelect from 'react-select/creatable'

export const creatableSelect_ = props => React.createElement(
  CreatableSelect,
  {
    ...props,
    classNames: {
      control: () => 'dark:bg-slate-700 dark:border-slate-600 shadow-none focus-within:border-cyan-600',
      input: () => 'dark:text-white',
      menu: () => 'dark:bg-slate-700',
      option: args => args.isFocused ? 'bg-cyan-50 dark:bg-slate-600' : '',
      placeholder: () => 'dark:text-white'
    }
  }
)
